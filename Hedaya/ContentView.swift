import SwiftUI

struct ContentView: View {
    let groups = AzkarData.allGroups
    @EnvironmentObject private var prayerTracker: PrayerTrackingStore
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Text("﷽")
                            .font(.system(size: 32))
                            .foregroundStyle(Color(hex: "1B5E3A"))
                        
                        Text("هداية")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "1B7A4A"), Color(hex: "2ECC71")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("حَصِّن يومك بذكر الله")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(hex: "2D4A3E"))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Groups Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        // General Sebha (counter)
                        NavigationLink(destination: GeneralSebhaView()) {
                            GeneralSebhaCard()
                        }
                        ForEach(groups) { group in
                            NavigationLink(destination: AzkarGroupView(group: group)) {
                                GroupCard(group: group)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HomeBottomBar()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "F0F7F4"),
                        Color(hex: "E8F5E9"),
                        Color(hex: "F5F5F5")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .environment(\.layoutDirection, .rightToLeft)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                prayerTracker.refreshTodayLog()  // day may have changed while app was backgrounded
            }
        }
    }
}

// MARK: - Home bottom bar (horizontal panel)
struct HomeBottomBar: View {
    var body: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: MyWorshipPathView()) {
                HomeBarPill(icon: "leaf.circle.fill", title: "مسيرتي")
            }
            NavigationLink(destination: GeneralSebhaView()) {
                HomeBarPill(icon: "circle.hexagongrid.fill", title: "سبحة")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.85))
    }
}

private struct HomeBarPill: View {
    let icon: String
    let title: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
            Text(title)
                .font(.system(size: 15, weight: .semibold))
        }
        .foregroundStyle(Color(hex: "1B7A4A"))
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(hex: "1B7A4A").opacity(0.12))
        )
        .frame(maxWidth: .infinity)
    }
}

// MARK: - General Sebha Card
struct GeneralSebhaCard: View {
    private let gradientColors: [Color] = [Color(hex: "1B7A4A"), Color(hex: "2ECC71")]
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.25))
                    .frame(width: 60, height: 60)
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
            Text("سبحة عامة")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("عدّاد ذكر")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: gradientColors[0].opacity(0.4), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Group Card
struct GroupCard: View {
    let group: AzkarGroup
    
    private var gradientColors: [Color] {
        switch group.color {
        case "morning":
            return [Color(hex: "F39C12"), Color(hex: "F1C40F")]
        case "evening":
            return [Color(hex: "2C3E50"), Color(hex: "3498DB")]
        case "prayer":
            return [Color(hex: "1B7A4A"), Color(hex: "2ECC71")]
        case "sleep":
            return [Color(hex: "8E44AD"), Color(hex: "9B59B6")]
        case "misc":
            return [Color(hex: "E74C3C"), Color(hex: "E67E22")]
        case "ad3ia":
            return [Color(hex: "0D7377"), Color(hex: "14A3B8")]
        default:
            return [Color(hex: "1B7A4A"), Color(hex: "2ECC71")]
        }
    }
    
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.25))
                    .frame(width: 60, height: 60)
                
                Image(systemName: group.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
            
            Text(group.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Text(group.tags.contains("Ad3ia") ? "\(group.azkar.count) أدعية" : "\(group.azkar.count) أذكار")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: gradientColors[0].opacity(0.4), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(PrayerTrackingStore())
}
