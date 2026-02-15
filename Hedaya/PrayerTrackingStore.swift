// MARK: - Prayer Tracking — State, persistence, prayer times

import Foundation
import SwiftUI
import CoreLocation
import Adhan

private enum StorageKey {
    static let dailyLogs = "hedaya.prayerTracking.dailyLogs"
    static let calculationMethod = "hedaya.prayerTracking.calculationMethod"
}

final class PrayerTrackingStore: ObservableObject {
    @Published private(set) var todayLog: PrayerDayLog
    @Published private(set) var prayerTimes: PrayerTimesToday?
    @Published private(set) var locationDescription: String?
    @Published var coordinate: CLLocationCoordinate2D? {
        didSet {
            computePrayerTimes()
            if let coord = coordinate {
                reverseGeocode(coord)
            } else {
                locationDescription = nil
            }
        }
    }

    private let geocoder = CLGeocoder()
    @Published var calculationMethod: PrayerCalculationMethod {
        didSet {
            defaults.set(calculationMethod.rawValue, forKey: StorageKey.calculationMethod)
            computePrayerTimes()
        }
    }

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private var dailyLogs: [String: PrayerDayLog] = [:]

    init() {
        self.todayLog = PrayerDayLog(dateKey: Self.dateKey(for: Date()))
        self.dailyLogs = Self.loadDailyLogs(from: UserDefaults.standard)
        let key = Self.dateKey(for: Date())
        self.todayLog = dailyLogs[key] ?? PrayerDayLog(dateKey: key)
        let methodRaw = UserDefaults.standard.string(forKey: StorageKey.calculationMethod)
            ?? PrayerCalculationMethod.muslimWorldLeague.rawValue
        self.calculationMethod = PrayerCalculationMethod(rawValue: methodRaw)
            ?? .muslimWorldLeague
    }

    static func dateKey(for date: Date = Date()) -> String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    private static func loadDailyLogs(from defaults: UserDefaults) -> [String: PrayerDayLog] {
        guard let data = defaults.data(forKey: StorageKey.dailyLogs),
              let decoded = try? JSONDecoder().decode([String: PrayerDayLog].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveDailyLogs() {
        guard let data = try? encoder.encode(dailyLogs) else { return }
        defaults.set(data, forKey: StorageKey.dailyLogs)
    }

    private func reverseGeocode(_ coord: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self, let pm = placemarks?.first else { return }
            let parts = [pm.locality, pm.administrativeArea, pm.country].compactMap { $0 }
            DispatchQueue.main.async {
                self.locationDescription = parts.isEmpty ? nil : parts.joined(separator: ", ")
            }
        }
    }

    private func computePrayerTimes() {
        guard let coord = coordinate else {
            prayerTimes = nil
            return
        }
        let cal = Calendar.current
        let dateComponents = cal.dateComponents([.year, .month, .day], from: Date())
        let params: CalculationParameters = {
            switch calculationMethod {
            case .muslimWorldLeague: return CalculationMethod.muslimWorldLeague.params
            case .egyptian: return CalculationMethod.egyptian.params
            case .northAmerica: return CalculationMethod.northAmerica.params
            case .makkah: return CalculationMethod.ummAlQura.params
            case .karachi: return CalculationMethod.karachi.params
            case .turkey: return CalculationMethod.turkey.params
            }
        }()
        let coordinates = Coordinates(latitude: coord.latitude, longitude: coord.longitude)
        guard let adhanTimes = PrayerTimes(coordinates: coordinates, date: dateComponents, calculationParameters: params) else {
            prayerTimes = nil
            return
        }
        prayerTimes = PrayerTimesToday(
            fajr: adhanTimes.fajr,
            sunrise: adhanTimes.sunrise,
            dhuhr: adhanTimes.dhuhr,
            asr: adhanTimes.asr,
            maghrib: adhanTimes.maghrib,
            isha: adhanTimes.isha
        )
    }

    func refreshTodayLog() {
        let key = Self.dateKey(for: Date())
        todayLog = dailyLogs[key] ?? PrayerDayLog(dateKey: key)
    }

    func isGlowing(for prayer: PrayerName) -> Bool {
        guard let times = prayerTimes else { return false }
        let now = Date()
        let prayerTime = times.time(for: prayer)
        return now >= prayerTime && !todayLog.prayersCompleted.contains(prayer)
    }

    func markPrayerDone(_ prayer: PrayerName) {
        var log = todayLog
        log.prayersCompleted.insert(prayer)
        todayLog = log
        dailyLogs[log.dateKey] = log
        saveDailyLogs()
    }

    func markSunriseSunnahDone() {
        var log = todayLog
        log.sunriseSunnahDone = true
        todayLog = log
        dailyLogs[log.dateKey] = log
        saveDailyLogs()
    }

    func markSunnahDone(_ prayer: PrayerName) {
        var log = todayLog
        log.sunnahCompleted.insert(prayer)
        todayLog = log
        dailyLogs[log.dateKey] = log
        saveDailyLogs()
    }

    func markQuranDone() {
        var log = todayLog
        log.quranDone = true
        todayLog = log
        dailyLogs[log.dateKey] = log
        saveDailyLogs()
    }

    func markBranchDone(_ branch: BranchType) {
        var log = todayLog
        log.branchesCompleted.insert(branch)
        todayLog = log
        dailyLogs[log.dateKey] = log
        saveDailyLogs()
    }
}
