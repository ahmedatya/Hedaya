package hedaya.shared

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

private val json = Json { ignoreUnknownKeys = true }

@Serializable
private data class GroupDTO(
    val id: String,
    val name: String,
    val icon: String,
    val color: String,
    val tags: List<String>,
    val order: Int
)

@Serializable
private data class ZikrEntry(
    val text: String,
    val repetitions: Int,
    val reference: String
)

/**
 * Parses groups JSON and loads each group's azkar via [azkarReader].
 * Returns groups sorted by `order`. Use this from both iOS (Swift passes Bundle-backed reader) and Android (pass asset reader).
 */
fun parseGroups(
    groupsJson: String,
    azkarReader: (groupId: String) -> String?
): List<AzkarGroup> {
    val dtos = runCatching {
        json.decodeFromString<List<GroupDTO>>(groupsJson)
    }.getOrNull() ?: return emptyList()
    val sorted = dtos.sortedBy { it.order }
    return sorted.map { dto ->
        val azkarJson = azkarReader(dto.id) ?: ""
        val entries = runCatching {
            json.decodeFromString<List<ZikrEntry>>(azkarJson)
        }.getOrNull() ?: emptyList()
        val azkar = entries.map { e -> Zikr(text = e.text, repetitions = e.repetitions, reference = e.reference) }
        AzkarGroup(
            id = dto.id,
            name = dto.name,
            icon = dto.icon,
            color = dto.color,
            tags = dto.tags,
            azkar = azkar
        )
    }
}
