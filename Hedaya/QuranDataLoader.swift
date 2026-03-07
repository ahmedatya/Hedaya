import Foundation

// MARK: - Quran Data Loader

/// Loads all 114 surahs and the 604 Mushaf pages from Data/quran.json.
enum QuranDataLoader {

    private static var cachedSurahs: [QuranSurah]?
    private static var cachedPages: [QuranPage]?

    static var allSurahs: [QuranSurah] {
        if let cached = cachedSurahs { return cached }
        let loaded = loadSurahs()
        cachedSurahs = loaded
        return loaded
    }

    static var allPages: [QuranPage] {
        if let cached = cachedPages { return cached }
        let pages = buildPages(from: allSurahs)
        cachedPages = pages
        return pages
    }

    /// Returns the 0-based index into allPages for the given 1-based Mushaf page number.
    static func pageIndex(forMushafPage page: Int) -> Int {
        max(0, min(page - 1, allPages.count - 1))
    }

    /// Returns the 0-based index into allPages where the given surah begins.
    static func pageIndex(forSurah surahNumber: Int) -> Int {
        guard let surah = allSurahs.first(where: { $0.id == surahNumber }) else { return 0 }
        return pageIndex(forMushafPage: surah.firstPage)
    }

    // MARK: - Private

    private static func loadSurahs() -> [QuranSurah] {
        guard let url = Bundle.main.url(forResource: "quran", withExtension: "json", subdirectory: "Data")
                     ?? Bundle.main.url(forResource: "quran", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dtos = try? JSONDecoder().decode([QuranSurahDTO].self, from: data) else {
            return []
        }
        return dtos.map { dto in
            QuranSurah(
                id: dto.number,
                name: dto.name,
                englishName: dto.englishName,
                ayahCount: dto.numberOfAyahs,
                revelationType: dto.revelationType,
                ayahs: dto.ayahs.map {
                    QuranAyah(id: $0.number, surahNumber: dto.number, text: $0.text, page: $0.page)
                }
            )
        }
    }

    private static func buildPages(from surahs: [QuranSurah]) -> [QuranPage] {
        let surahByNumber = Dictionary(uniqueKeysWithValues: surahs.map { ($0.id, $0) })

        // Flatten all ayahs and group by Mushaf page number
        let allAyahs = surahs.flatMap { $0.ayahs }
        let byPage = Dictionary(grouping: allAyahs, by: { $0.page })

        return byPage.keys.sorted().map { pageNum in
            // Sort ayahs on this page by (surahNumber, ayahId)
            let sorted = byPage[pageNum]!.sorted {
                $0.surahNumber != $1.surahNumber ? $0.surahNumber < $1.surahNumber : $0.id < $1.id
            }

            // Group consecutive ayahs by surah into segments
            var segments: [QuranPageSegment] = []
            var groupSurah: Int? = nil
            var groupAyahs: [QuranAyah] = []

            func flush() {
                guard let s = groupSurah, !groupAyahs.isEmpty else { return }
                let surah = surahByNumber[s]!
                let isStart = groupAyahs.first!.id == 1
                segments.append(QuranPageSegment(
                    surahNumber: s,
                    surahName: surah.name,
                    showSurahHeader: isStart,
                    showBasmala: isStart && s != 1 && s != 9,
                    ayahs: groupAyahs
                ))
            }

            for ayah in sorted {
                if ayah.surahNumber != groupSurah {
                    flush()
                    groupSurah = ayah.surahNumber
                    groupAyahs = []
                }
                groupAyahs.append(ayah)
            }
            flush()

            return QuranPage(id: pageNum, segments: segments)
        }
    }
}
