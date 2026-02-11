import Foundation

/// A single Zikr (prayer/remembrance) with its Arabic text and recommended repetition count
struct Zikr: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let repetitions: Int
    let reference: String // Source/reference for the Zikr
}

/// A group of Azkar (e.g. Morning Azkar, Evening Azkar, Ad3ia). Id matches the group key in Data (e.g. "morning", "ad3ia_most_popular").
struct AzkarGroup: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: String
    let tags: [String]  // e.g. ["Ad3ia", "MostPopular"] for أدعية
    let azkar: [Zikr]
}
