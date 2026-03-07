// MARK: - Quran Data Models

import Foundation

// MARK: - JSON DTOs

struct QuranSurahDTO: Decodable {
    let number: Int
    let name: String
    let englishName: String
    let numberOfAyahs: Int
    let revelationType: String
    let ayahs: [QuranAyahDTO]
}

struct QuranAyahDTO: Decodable {
    let number: Int   // numberInSurah (remapped on disk)
    let text: String
    let page: Int
}

// MARK: - App Models

struct QuranSurah: Identifiable {
    let id: Int          // surah number 1–114
    let name: String
    let englishName: String
    let ayahCount: Int
    let revelationType: String
    let ayahs: [QuranAyah]
    /// Mushaf page where this surah begins
    var firstPage: Int { ayahs.first?.page ?? 1 }
}

struct QuranAyah: Identifiable {
    let id: Int           // 1-based ayah number within surah
    let surahNumber: Int
    let text: String
    let page: Int
}

// MARK: - Mushaf Page Layout

/// One run of consecutive ayahs from the same surah on a single Mushaf page.
struct QuranPageSegment {
    let surahNumber: Int
    let surahName: String
    /// True when this segment starts at ayah 1 of the surah (show surah name header).
    let showSurahHeader: Bool
    /// True when showSurahHeader && it is not Al-Fatiha (1) or At-Tawbah (9).
    let showBasmala: Bool
    let ayahs: [QuranAyah]
}

/// One Mushaf page (1–604), containing one or more segments.
struct QuranPage: Identifiable {
    let id: Int   // 1-based Mushaf page number
    let segments: [QuranPageSegment]

    /// Name of the first surah on this page (used in toolbar).
    var primarySurahName: String { segments.first?.surahName ?? "" }
    /// First ayah on the page (for progress tracking).
    var firstAyah: QuranAyah? { segments.first?.ayahs.first }
}

// MARK: - Reading Progress

struct QuranReadingProgress: Codable {
    var lastSurahNumber: Int
    var lastAyahNumber: Int
    var lastPageNumber: Int

    static let initial = QuranReadingProgress(
        lastSurahNumber: 1, lastAyahNumber: 1, lastPageNumber: 1
    )

    // Custom decode so old data without lastPageNumber defaults gracefully.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        lastSurahNumber = try c.decode(Int.self, forKey: .lastSurahNumber)
        lastAyahNumber  = try c.decode(Int.self, forKey: .lastAyahNumber)
        lastPageNumber  = try c.decodeIfPresent(Int.self, forKey: .lastPageNumber) ?? 1
    }

    init(lastSurahNumber: Int, lastAyahNumber: Int, lastPageNumber: Int) {
        self.lastSurahNumber = lastSurahNumber
        self.lastAyahNumber  = lastAyahNumber
        self.lastPageNumber  = lastPageNumber
    }
}
