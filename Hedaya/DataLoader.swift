import Foundation

// MARK: - JSON DTOs (data only, no app logic)

private struct GroupDTO: Decodable {
    let id: String
    let name: String
    let icon: String
    let color: String
    let tags: [String]
    let order: Int
}

private struct ZikrEntry: Decodable {
    let text: String
    let repetitions: Int
    let reference: String
}

// MARK: - Data Loader

/// Loads azkar groups and their content from JSON in the Data folder. Keeps data separate from app logic.
enum DataLoader {

    private static let groupsFilename = "groups"
    private static let azkarSubfolder = "azkar"

    /// Loads all groups from Data/groups.json and each group's azkar from Data/azkar/<id>.json.
    /// Returns groups sorted by `order`. Returns empty array if loading fails.
    static func loadGroups(bundle: Bundle = .main) -> [AzkarGroup] {
        guard let groupsURL = bundle.url(forResource: groupsFilename, withExtension: "json", subdirectory: "Data")
              ?? bundle.url(forResource: groupsFilename, withExtension: "json"),
              let data = try? Data(contentsOf: groupsURL),
              let dtos = try? JSONDecoder().decode([GroupDTO].self, from: data) else {
            return []
        }

        let sortedDTOs = dtos.sorted { $0.order < $1.order }
        var result: [AzkarGroup] = []

        for dto in sortedDTOs {
            let azkar = loadAzkar(for: dto.id, bundle: bundle)
            let group = AzkarGroup(
                id: dto.id,
                name: dto.name,
                icon: dto.icon,
                color: dto.color,
                tags: dto.tags,
                azkar: azkar
            )
            result.append(group)
        }

        return result
    }

    /// Loads azkar array from Data/azkar/<groupId>.json. Returns empty array if file missing or invalid.
    private static func loadAzkar(for groupId: String, bundle: Bundle) -> [Zikr] {
        let azkarSubpath = "Data/\(azkarSubfolder)"
        guard let url = bundle.url(forResource: groupId, withExtension: "json", subdirectory: azkarSubpath)
            ?? bundle.url(forResource: groupId, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([ZikrEntry].self, from: data) else {
            return []
        }
        return entries.enumerated().map { index, entry in
            Zikr(
                text: entry.text,
                repetitions: entry.repetitions,
                reference: entry.reference
            )
        }
    }
}
