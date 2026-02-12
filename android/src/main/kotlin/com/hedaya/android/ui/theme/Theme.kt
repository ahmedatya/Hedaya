package com.hedaya.android.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val Primary = Color(0xFF1B7A4A)
private val PrimaryVariant = Color(0xFF2ECC71)
private val OnPrimary = Color.White
private val SurfaceLight = Color(0xFFF0F7F4)
private val SurfaceVariant = Color(0xFFE8F5E9)
private val SurfaceVariant2 = Color(0xFFF5F5F5)
private val OnSurface = Color(0xFF2C3E50)
private val OnSurfaceVariant = Color(0xFF2D4A3E)

private val LightColorScheme = lightColorScheme(
    primary = Primary,
    onPrimary = OnPrimary,
    surface = SurfaceLight,
    onSurface = OnSurface
)

@Composable
fun HedayaTheme(
    content: @Composable () -> Unit
) {
    val colorScheme = LightColorScheme
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as? Activity)?.window
            window?.statusBarColor = colorScheme.surface.toArgb()
            WindowCompat.getInsetsController(window!!, view).isAppearanceLightStatusBar = true
        }
    }
    MaterialTheme(
        colorScheme = colorScheme,
        typography = com.hedaya.android.ui.theme.Typography,
        content = content
    )
}

object HedayaColors {
    val PrimaryGreen = Color(0xFF1B7A4A)
    val PrimaryGreenLight = Color(0xFF2ECC71)
    val MorningStart = Color(0xFFF39C12)
    val MorningEnd = Color(0xFFF1C40F)
    val EveningStart = Color(0xFF2C3E50)
    val EveningEnd = Color(0xFF3498DB)
    val PrayerStart = Color(0xFF1B7A4A)
    val PrayerEnd = Color(0xFF2ECC71)
    val SleepStart = Color(0xFF8E44AD)
    val SleepEnd = Color(0xFF9B59B6)
    val MiscStart = Color(0xFFE74C3C)
    val MiscEnd = Color(0xFFE67E22)
    val Ad3iaStart = Color(0xFF0D7377)
    val Ad3iaEnd = Color(0xFF14A3B8)
    val TextSecondary = Color(0xFF2D4A3E)
}
