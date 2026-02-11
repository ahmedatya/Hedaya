import Foundation

/// Provides azkar groups loaded from JSON in the Data folder. Data lives in Hedaya/Data/; app logic stays here.
enum AzkarData {

    private static var cachedGroups: [AzkarGroup]?

    /// All groups (metadata from Data/groups.json, content from Data/azkar/<id>.json). Cached after first load.
    static var allGroups: [AzkarGroup] {
        if let cached = cachedGroups { return cached }
        let loaded = DataLoader.loadGroups()
        cachedGroups = loaded
        return loaded
    }

    /// Reload from disk (e.g. after adding new JSON). Clears cache.
    static func reload() {
        cachedGroups = nil
    }
}
