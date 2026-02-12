package hedaya.shared

import kotlinx.serialization.Serializable

/** A single Zikr (prayer/remembrance) with its Arabic text and recommended repetition count */
@Serializable
data class Zikr(
    val text: String,
    val repetitions: Int,
    val reference: String
)

/** A group of Azkar (e.g. Morning Azkar, Evening Azkar, Ad3ia). Id matches the group key in Data. */
@Serializable
data class AzkarGroup(
    val id: String,
    val name: String,
    val icon: String,
    val color: String,
    val tags: List<String>,
    val azkar: List<Zikr>
)
