// MARK: - Azan notifications at prayer time

import Foundation
import UserNotifications
import AVFoundation

enum AzanNotificationManager {
    private static let soundFileName = "azan.wav"
    private static let identifierPrefix = "hedaya.azan."
    private static let playedTodayKeyPrefix = "hedaya.azan.played."

    static let playAzanSoundKey = "hedaya.azan.playSound"

    /// Schedules local notifications for each prayer time today. Call when prayer times are available and after they change.
    /// When `playAzanSound` is false, notifications are not scheduled (user has disabled Azan sound).
    static func scheduleIfNeeded(prayerTimes: PrayerTimesToday?, playAzanSound: Bool) {
        guard playAzanSound, let times = prayerTimes else {
            cancelAll()
            return
        }
        cancelAll()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                scheduleNotifications(for: times)
            }
        }
    }

    /// Removes all Hedaya Azan notification requests.
    static func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
            guard !ids.isEmpty else { return }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    private static func scheduleNotifications(for times: PrayerTimesToday) {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        for prayer in PrayerName.allCases {
            let date = times.time(for: prayer)
            guard date > Date() else { continue }
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let content = UNMutableNotificationContent()
            content.title = "أذان \(prayer.titleAr)"
            content.body = "حان وقت صلاة \(prayer.titleAr)"
            if Bundle.main.url(forResource: "azan", withExtension: "wav") != nil {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileName))
            } else {
                content.sound = .default
            }
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let id = "\(identifierPrefix)\(prayer.rawValue)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    // MARK: - In-app playback when app is in foreground at prayer time

    /// Call when the app is in foreground (e.g. on scenePhase == .active). If current time is within a short window after a prayer time and Azan sound is enabled, plays the Azan once per prayer per day.
    static func playAzanIfNeeded(prayerTimes: PrayerTimesToday?, playAzanSound: Bool) {
        guard playAzanSound, let times = prayerTimes else { return }
        let now = Date()
        let calendar = Calendar.current
        let dateKey = PrayerTrackingStore.dateKey(for: now)
        let defaults = UserDefaults.standard
        var played = Set(defaults.stringArray(forKey: playedTodayKeyPrefix + dateKey) ?? [])
        for prayer in PrayerName.allCases {
            let prayerTime = times.time(for: prayer)
            let interval = now.timeIntervalSince(prayerTime)
            if interval >= 0, interval <= 120, !played.contains(prayer.rawValue) {
                playAzanSoundFile()
                played.insert(prayer.rawValue)
                defaults.set(Array(played), forKey: playedTodayKeyPrefix + dateKey)
                break
            }
        }
    }

    private static var azanPlayer: AVAudioPlayer?

    private static func playAzanSoundFile() {
        guard let url = Bundle.main.url(forResource: "azan", withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            azanPlayer = try AVAudioPlayer(contentsOf: url)
            azanPlayer?.play()
        } catch {}
    }
}
