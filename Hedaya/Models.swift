import Foundation

/// A single Zikr (prayer/remembrance) with its Arabic text and recommended repetition count
struct Zikr: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let repetitions: Int
    let reference: String // Source/reference for the Zikr
}

/// A group of Azkar (e.g. Morning Azkar, Evening Azkar)
struct AzkarGroup: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let azkar: [Zikr]
}
