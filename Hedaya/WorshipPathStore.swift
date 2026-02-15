// MARK: - My Worship Path — Persistence & progress logic

import Foundation
import SwiftUI

private enum StorageKey {
    static let profile = "hedaya.worshipPath.profile"
    static let dailyLogs = "hedaya.worshipPath.dailyLogs"
    static let progress = "hedaya.worshipPath.progress"
}

final class WorshipPathStore: ObservableObject {
    @Published private(set) var profile: WorshipProfile
    @Published private(set) var dailyLogs: [String: DailyLog] = [:]
    @Published private(set) var progress: ProgressState

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()

    init() {
        self.profile = (try? Self.loadProfile(from: UserDefaults.standard)) ?? WorshipProfile()
        self.dailyLogs = Self.loadDailyLogs(from: UserDefaults.standard)
        self.progress = (try? Self.loadProgress(from: UserDefaults.standard)) ?? .default
        self.refreshProgressFromLogs()
    }

    static func dateKey(for date: Date = Date()) -> String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    private static func dateFrom(_ dateKey: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateKey)
    }

    private static func startOfWeekKey(for date: Date) -> String {
        let cal = Calendar.current
        guard let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return dateKey(for: date)
        }
        return dateKey(for: start)
    }

    func updateProfile(_ profile: WorshipProfile) {
        self.profile = profile
        saveProfile()
        applyProfileToProgress()
    }

    func completeOnboarding(with profile: WorshipProfile) {
        DebugLog.log("WorshipPathStore", "completeOnboarding called")
        var p = profile
        p.completedAt = Date()
        updateProfile(p)
        DebugLog.log("WorshipPathStore", "completeOnboarding done, hasCompletedOnboarding=\(p.hasCompletedOnboarding)")
    }

    private func applyProfileToProgress() {
        let mercy = profile.pace == .ambitious ? 1 : 2
        if progress.mercyDaysAllowedPerWeek != mercy {
            progress.mercyDaysAllowedPerWeek = mercy
            saveProgress()
        }
    }

    private static func loadProfile(from defaults: UserDefaults) throws -> WorshipProfile? {
        guard let data = defaults.data(forKey: StorageKey.profile) else { return nil }
        return try JSONDecoder().decode(WorshipProfile.self, from: data)
    }

    private func saveProfile() {
        guard let data = try? encoder.encode(profile) else { return }
        defaults.set(data, forKey: StorageKey.profile)
    }

    func log(for date: Date = Date()) -> DailyLog {
        let key = Self.dateKey(for: date)
        return dailyLogs[key] ?? DailyLog(dateKey: key)
    }

    func setLog(_ log: DailyLog) {
        dailyLogs[log.dateKey] = log
        saveDailyLogs()
        refreshProgressFromLogs()
    }

    func addAction(_ type: LoggedActionType, for date: Date = Date(), subtype: String? = nil) {
        let key = Self.dateKey(for: date)
        var dayLog = dailyLogs[key] ?? DailyLog(dateKey: key)
        dayLog.actions.append(LoggedAction(type: type, subtype: subtype, completedAt: Date()))
        dailyLogs[key] = dayLog
        saveDailyLogs()
        refreshProgressFromLogs()
    }

    func markGraceDay(for date: Date = Date()) {
        let key = Self.dateKey(for: date)
        var dayLog = dailyLogs[key] ?? DailyLog(dateKey: key)
        dayLog.usedGraceDay = true
        dailyLogs[key] = dayLog
        saveDailyLogs()
        refreshProgressFromLogs()
    }

    private static func loadDailyLogs(from defaults: UserDefaults) -> [String: DailyLog] {
        guard let data = defaults.data(forKey: StorageKey.dailyLogs),
              let decoded = try? JSONDecoder().decode([String: DailyLog].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveDailyLogs() {
        guard let data = try? encoder.encode(dailyLogs) else { return }
        defaults.set(data, forKey: StorageKey.dailyLogs)
    }

    func isOnPath(dateKey: String) -> Bool {
        guard let log = dailyLogs[dateKey] else { return false }
        if log.usedGraceDay { return true }
        return !log.actions.isEmpty
    }

    private func refreshProgressFromLogs() {
        let weekStart = Self.startOfWeekKey(for: Date())

        if progress.weekStartKey != weekStart {
            progress.weekStartKey = weekStart
        }
        var mercyUsed = 0
        for (key, log) in dailyLogs where log.usedGraceDay {
            let logWeekStart = Self.startOfWeekKey(for: Self.dateFrom(key) ?? Date())
            if logWeekStart == weekStart { mercyUsed += 1 }
        }
        progress.mercyDaysUsedThisWeek = mercyUsed

        var streak = 0
        let cal = Calendar.current
        var check = Date()
        for _ in 0..<365 {
            let key = Self.dateKey(for: check)
            if isOnPath(dateKey: key) {
                streak += 1
            } else {
                break
            }
            check = cal.date(byAdding: .day, value: -1, to: check) ?? check
        }
        progress.streakDays = streak

        let levelFromStreak: (Int) -> PathLevel = { s in
            if s >= 28 { return .blossom }
            if s >= 21 { return .steadfast }
            if s >= 14 { return .growth }
            if s >= 7 { return .roots }
            return .seeds
        }
        let newLevel = levelFromStreak(streak)
        if newLevel != progress.currentLevel {
            progress.currentLevel = newLevel
        }
        let prevMilestone: [PathLevel: Int] = [.seeds: 0, .roots: 7, .growth: 14, .steadfast: 21, .blossom: 28]
        let nextMilestone: [PathLevel: Int] = [.seeds: 7, .roots: 14, .growth: 21, .steadfast: 28, .blossom: 28]
        let prev = prevMilestone[progress.currentLevel] ?? 0
        let next = nextMilestone[progress.currentLevel] ?? 7
        let range = next - prev
        progress.levelProgress = range > 0 ? min(1.0, Double(streak - prev) / Double(range)) : 1.0

        saveProgress()
    }

    private static func loadProgress(from defaults: UserDefaults) throws -> ProgressState? {
        guard let data = defaults.data(forKey: StorageKey.progress) else { return nil }
        return try JSONDecoder().decode(ProgressState.self, from: data)
    }

    private func saveProgress() {
        guard let data = try? encoder.encode(progress) else { return }
        defaults.set(data, forKey: StorageKey.progress)
    }

    func dailyEssentials() -> [PlanEssentialItem] {
        profile.dailyEssentials()
    }

    func optionalBonuses() -> [PlanBonusItem] {
        let areas = profile.worshipAreas.isEmpty ? WorshipArea.allCases : profile.worshipAreas
        var items: [PlanBonusItem] = []
        if areas.contains(.salah) {
            items.append(PlanBonusItem(titleAr: "سنة الفجر", actionType: .sunnahFajr))
            items.append(PlanBonusItem(titleAr: "سنة الظهر", actionType: .sunnahDhuhr))
            items.append(PlanBonusItem(titleAr: "سنة العصر", actionType: .sunnahAsr))
            items.append(PlanBonusItem(titleAr: "سنة المغرب", actionType: .sunnahMaghrib))
            items.append(PlanBonusItem(titleAr: "سنة العشاء", actionType: .sunnahIsha))
        }
        if areas.contains(.sadaqah) { items.append(PlanBonusItem(titleAr: "صدقة", actionType: .sadaqah)) }
        if areas.contains(.dua) { items.append(PlanBonusItem(titleAr: "دعاء من القلب", actionType: .dua)) }
        if areas.contains(.goodDeeds) { items.append(PlanBonusItem(titleAr: "نية حسنة أو عمل صالح", actionType: .goodDeed)) }
        // Extras: always shown
        items.append(PlanBonusItem(titleAr: "قيام الليل", actionType: .qiyamAlLayl))
        items.append(PlanBonusItem(titleAr: "ذكر إضافي", actionType: .extraDhikr))
        items.append(PlanBonusItem(titleAr: "دعاء إضافي", actionType: .extraDua))
        return items
    }

    func weeklyFocusAr() -> String {
        let themes = ["دعاء بعد الصلاة", "ذكر قصير بعد كل صلاة", "آية واحدة مع تدبر", "نية واحدة صادقة"]
        let week = Calendar.current.component(.weekOfYear, from: Date())
        return themes[week % themes.count]
    }

    func clearAllPathData() {
        profile = WorshipProfile()
        dailyLogs = [:]
        progress = .default
        defaults.removeObject(forKey: StorageKey.profile)
        defaults.removeObject(forKey: StorageKey.dailyLogs)
        defaults.removeObject(forKey: StorageKey.progress)
    }
}
