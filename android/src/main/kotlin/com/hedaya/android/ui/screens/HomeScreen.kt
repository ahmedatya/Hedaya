package com.hedaya.android.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.hedaya.android.ui.theme.HedayaColors
import hedaya.shared.AzkarGroup

private val BackgroundGradient = Brush.verticalGradient(
    colors = listOf(
        Color(0xFFF0F7F4),
        Color(0xFFE8F5E9),
        Color(0xFFF5F5F5)
    )
)

@Composable
fun HomeScreen(
    groups: List<AzkarGroup>,
    onGeneralSebhaClick: () -> Unit,
    onGroupClick: (AzkarGroup) -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(BackgroundGradient)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp)
        ) {
            // Header
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 20.dp, bottom = 10.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "\uFDFD",
                    fontSize = 32.sp,
                    color = Color(0xFF1B5E3A)
                )
                Text(
                    text = "هداية",
                    fontSize = 40.sp,
                    fontWeight = FontWeight.Bold,
                    color = HedayaColors.PrimaryGreen
                )
                Text(
                    text = "حَصِّن يومك بذكر الله",
                    fontSize = 16.sp,
                    color = HedayaColors.TextSecondary
                )
            }
            // Grid
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                contentPadding = PaddingValues(bottom = 30.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                item {
                    GeneralSebhaCard(onClick = onGeneralSebhaClick)
                }
                items(groups) { group ->
                    GroupCard(group = group, onClick = { onGroupClick(group) })
                }
            }
        }
    }
}

@Composable
private fun GeneralSebhaCard(onClick: () -> Unit) {
    val gradient = Brush.linearGradient(
        colors = listOf(HedayaColors.PrimaryGreen, HedayaColors.PrimaryGreenLight)
    )
    CardWithGradient(
        gradient = gradient,
        icon = "⛓",
        title = "سبحة عامة",
        subtitle = "عدّاد ذكر",
        onClick = onClick
    )
}

@Composable
private fun GroupCard(
    group: AzkarGroup,
    onClick: () -> Unit
) {
    val (start, end) = when (group.color) {
        "morning" -> HedayaColors.MorningStart to HedayaColors.MorningEnd
        "evening" -> HedayaColors.EveningStart to HedayaColors.EveningEnd
        "prayer" -> HedayaColors.PrayerStart to HedayaColors.PrayerEnd
        "sleep" -> HedayaColors.SleepStart to HedayaColors.SleepEnd
        "misc" -> HedayaColors.MiscStart to HedayaColors.MiscEnd
        "ad3ia" -> HedayaColors.Ad3iaStart to HedayaColors.Ad3iaEnd
        else -> HedayaColors.PrimaryGreen to HedayaColors.PrimaryGreenLight
    }
    val subtitle = if (group.tags.contains("Ad3ia")) "${group.azkar.size} أدعية" else "${group.azkar.size} أذكار"
    val iconEmoji = when (group.color) {
        "morning" -> "☀️"
        "evening" -> "🌙"
        "prayer" -> "🤲"
        "sleep" -> "🛏"
        "misc" -> "✨"
        "ad3ia" -> "📿"
        else -> "📖"
    }
    CardWithGradient(
        gradient = Brush.linearGradient(colors = listOf(start, end)),
        icon = iconEmoji,
        title = group.name,
        subtitle = subtitle,
        onClick = onClick
    )
}

@Composable
private fun CardWithGradient(
    gradient: Brush,
    icon: String,
    title: String,
    subtitle: String,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(8.dp, RoundedCornerShape(20.dp))
            .clip(RoundedCornerShape(20.dp))
            .background(gradient)
            .clickable(onClick = onClick)
            .padding(vertical = 24.dp, horizontal = 12.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.padding(8.dp)
            ) {
                Text(text = icon, fontSize = 28.sp, color = Color.White.copy(alpha = 0.9f))
            }
            Text(
                text = title,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                textAlign = TextAlign.Center
            )
            Text(
                text = subtitle,
                fontSize = 13.sp,
                color = Color.White.copy(alpha = 0.85f)
            )
        }
    }
}
