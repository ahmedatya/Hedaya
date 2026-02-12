import Foundation

#if canImport(shared)
import shared
#endif

/// Loads azkar groups: uses the KMP shared framework when linked (e.g. after building with scripts/build-ios-framework.sh), otherwise falls back to DataLoader.
enum SharedAzkarLoader {

    static var allGroups: [AzkarGroup] {
#if canImport(shared)
        return loadFromSharedFramework()
#else
        return DataLoader.loadGroups(bundle: .main)
#endif
    }

#if canImport(shared)
    private static func loadFromSharedFramework() -> [AzkarGroup] {
        guard let groupsURL = Bundle.main.url(forResource: "groups", withExtension: "json", subdirectory: "Data"),
              let groupsData = try? Data(contentsOf: groupsURL),
              let groupsJson = String(data: groupsData, encoding: .utf8) else {
            return []
        }
        let azkarReader: (String) -> String? = { groupId in
            let subpath = "Data/azkar"
            guard let url = Bundle.main.url(forResource: groupId, withExtension: "json", subdirectory: subpath)
                ?? Bundle.main.url(forResource: groupId, withExtension: "json"),
                  let data = try? Data(contentsOf: url) else { return nil }
            return String(data: data, encoding: .utf8)
        }
        let parsed = HedayaSharedDataLoaderKt.parseGroups(groupsJson: groupsJson, azkarReader: azkarReader)
        return parsed.map { group in
            AzkarGroup(
                id: group.id,
                name: group.name,
                icon: group.icon,
                color: group.color,
                tags: group.tags,
                azkar: group.azkar.map { z in
                    Zikr(
                        text: z.text,
                        repetitions: Int(z.repetitions),
                        reference: z.reference
                    )
                }
            )
        }
    }
#endif
}
