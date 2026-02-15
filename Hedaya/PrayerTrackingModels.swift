// MARK: - Prayer Tracking — Data models

import Foundation

enum PrayerName: String, Codable, CaseIterable {
    case fajr
    case dhuhr
    case asr
    case maghrib
    case isha

    var titleAr: String {
        switch self {
        case .fajr: return "الفجر"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }

    /// Asr has no regular sunnah before or after.
    var hasSunnah: Bool {
        self != .asr
    }
}

enum BranchType: String, Codable, CaseIterable {
    case sunnahPrayer
    case sadaqa
    case morningZikr
    case sleepingZikr
    case eveningZikr
    case extraDuaa
    case extraZikr
    case extraSalah

    var titleAr: String {
        switch self {
        case .sunnahPrayer: return "صلاة سنة"
        case .sadaqa: return "صدقة"
        case .morningZikr: return "أذكار الصباح"
        case .sleepingZikr: return "أذكار النوم"
        case .eveningZikr: return "أذكار المساء"
        case .extraDuaa: return "دعاء إضافي"
        case .extraZikr: return "ذكر إضافي"
        case .extraSalah: return "صلاة إضافية"
        }
    }
}

struct PrayerDayLog: Codable, Equatable {
    var dateKey: String
    var prayersCompleted: Set<PrayerName>
    var sunnahCompleted: Set<PrayerName>
    var sunriseSunnahDone: Bool
    var quranDone: Bool
    var branchesCompleted: Set<BranchType>
    var usedGraceDay: Bool

    init(dateKey: String, prayersCompleted: Set<PrayerName> = [], sunnahCompleted: Set<PrayerName> = [], sunriseSunnahDone: Bool = false, quranDone: Bool = false, branchesCompleted: Set<BranchType> = [], usedGraceDay: Bool = false) {
        self.dateKey = dateKey
        self.prayersCompleted = prayersCompleted
        self.sunnahCompleted = sunnahCompleted
        self.sunriseSunnahDone = sunriseSunnahDone
        self.quranDone = quranDone
        self.branchesCompleted = branchesCompleted
        self.usedGraceDay = usedGraceDay
    }
}

// Codable conformance for Set<PrayerName> and Set<BranchType> via array
extension PrayerDayLog {
    enum CodingKeys: String, CodingKey {
        case dateKey
        case prayersCompleted
        case sunnahCompleted
        case sunriseSunnahDone
        case quranDone
        case branchesCompleted
        case usedGraceDay
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        dateKey = try c.decode(String.self, forKey: .dateKey)
        let prayers = try c.decode([PrayerName].self, forKey: .prayersCompleted)
        prayersCompleted = Set(prayers)
        let sunnah = (try? c.decode([PrayerName].self, forKey: .sunnahCompleted)) ?? []
        sunnahCompleted = Set(sunnah)
        sunriseSunnahDone = (try? c.decode(Bool.self, forKey: .sunriseSunnahDone)) ?? false
        quranDone = try c.decode(Bool.self, forKey: .quranDone)
        let branches = (try? c.decode([BranchType].self, forKey: .branchesCompleted)) ?? []
        branchesCompleted = Set(branches)
        usedGraceDay = (try? c.decode(Bool.self, forKey: .usedGraceDay)) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(dateKey, forKey: .dateKey)
        try c.encode(Array(prayersCompleted), forKey: .prayersCompleted)
        try c.encode(Array(sunnahCompleted), forKey: .sunnahCompleted)
        try c.encode(sunriseSunnahDone, forKey: .sunriseSunnahDone)
        try c.encode(quranDone, forKey: .quranDone)
        try c.encode(Array(branchesCompleted), forKey: .branchesCompleted)
        try c.encode(usedGraceDay, forKey: .usedGraceDay)
    }
}

/// Calculation methods for prayer times. Maps to Adhan CalculationMethod.
enum PrayerCalculationMethod: String, CaseIterable, Codable {
    case muslimWorldLeague = "muslimWorldLeague"
    case egyptian = "egyptian"
    case northAmerica = "northAmerica"
    case makkah = "makkah"
    case karachi = "karachi"
    case turkey = "turkey"

    var titleAr: String {
        switch self {
        case .muslimWorldLeague: return "رابطة العالم الإسلامي"
        case .egyptian: return "الهيئة المصرية"
        case .northAmerica: return "أمريكا الشمالية"
        case .makkah: return "أم القرى"
        case .karachi: return "كراتشي"
        case .turkey: return "تركيا"
        }
    }
}

struct PrayerTimesToday {
    var fajr: Date
    var sunrise: Date
    var dhuhr: Date
    var asr: Date
    var maghrib: Date
    var isha: Date

    func time(for prayer: PrayerName) -> Date {
        switch prayer {
        case .fajr: return fajr
        case .dhuhr: return dhuhr
        case .asr: return asr
        case .maghrib: return maghrib
        case .isha: return isha
        }
    }
}
