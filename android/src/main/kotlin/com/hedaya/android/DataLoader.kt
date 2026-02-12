package com.hedaya.android

import android.content.Context
import hedaya.shared.AzkarGroup
import hedaya.shared.parseGroups
import java.io.InputStreamReader

fun loadGroupsFromAssets(context: Context): List<AzkarGroup> {
    val groupsJson = context.assets.open("data/groups.json").use { stream ->
        InputStreamReader(stream).readText()
    }
    return parseGroups(groupsJson) { groupId ->
        runCatching {
            context.assets.open("data/azkar/$groupId.json").use { stream ->
                InputStreamReader(stream).readText()
            }
        }.getOrNull()
    }
}
