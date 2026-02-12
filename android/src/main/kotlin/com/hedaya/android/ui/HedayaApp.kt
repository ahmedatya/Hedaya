package com.hedaya.android.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import hedaya.shared.AzkarGroup
import com.hedaya.android.ui.screens.AzkarGroupScreen
import com.hedaya.android.ui.screens.GeneralSebhaScreen
import com.hedaya.android.ui.screens.HomeScreen

@Composable
fun HedayaApp(
    groups: List<AzkarGroup>,
    navController: androidx.navigation.NavController
) {
    CompositionLocalProvider(
        LocalLayoutDirection provides LayoutDirection.Rtl
    ) {
        NavHost(
            navController = navController,
            startDestination = "home"
        ) {
            composable("home") {
                HomeScreen(
                    groups = groups,
                    onGeneralSebhaClick = { navController.navigate("sebha") },
                    onGroupClick = { group ->
                        val index = groups.indexOf(group)
                        navController.navigate("group/$index")
                    }
                )
            }
            composable("sebha") {
                GeneralSebhaScreen(onBack = { navController.popBackStack() })
            }
            composable(
                route = "group/{index}",
                arguments = listOf(navArgument("index") { type = NavType.IntType })
            ) { backStackEntry ->
                val index = backStackEntry.arguments?.getInt("index") ?: 0
                val group = groups.getOrNull(index) ?: return@composable
                AzkarGroupScreen(
                    group = group,
                    onBack = { navController.popBackStack() }
                )
            }
        }
    }
}
