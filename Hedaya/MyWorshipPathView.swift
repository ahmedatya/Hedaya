// MARK: - My Worship Path — Container & main views

import SwiftUI

struct MyWorshipPathView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = WorshipPathStore()
    @State private var screen: PathScreen = .intro

    private enum PathScreen {
        case intro
        case onboarding
        case plan
        case tree
    }

    var body: some View {
        Group {
            switch screen {
            case .intro:
                WorshipPathIntroView(onStart: { screen = .onboarding }, onSkip: { dismiss() })
            case .onboarding:
                WorshipPathOnboardingView(store: store, onComplete: { profile in
                    DebugLog.log("WorshipPath", "Onboarding onComplete, switching to .plan")
                    store.completeOnboarding(with: profile)
                    screen = .plan
                })
            case .plan:
                WorshipPathPlanView(store: store, onContinue: { screen = .tree })
            case .tree:
                PrayerTrackingView()
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            if store.profile.hasCompletedOnboarding {
                screen = .tree
            }
        }
    }
}

struct WorshipPathIntroView: View {
    var onStart: () -> Void
    var onSkip: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("﷽")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "1B5E3A"))
                Text("مسيرتك في العبادة")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "1B7A4A"))
                    .multilineTextAlignment(.center)
                Text("خطوة بخطوة، وفق وقتك ونيتك، بدون ضغط ولا مقارنة.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: "2D4A3E"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text("هنا نرتب معاً ما تريد أن تركز عليه من صلاة وذكر وقراءة وصدقة، ونضع خطة بسيطة تتكيف مع أيامك.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "2D4A3E").opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                VStack(spacing: 14) {
                    Button(action: onStart) {
                        Text("ابدأ مسيرتي")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "1B7A4A"), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                    Button(action: onSkip) {
                        Text("تخطى الآن")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(hex: "2D4A3E").opacity(0.8))
                    }
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 40)
        }
        .background(LinearGradient(colors: [Color(hex: "F0F7F4"), Color(hex: "E8F5E9"), Color(hex: "F5F5F5")], startPoint: .top, endPoint: .bottom))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WorshipPathPlanView: View {
    @ObservedObject var store: WorshipPathStore
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("خطتك في العبادة")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(hex: "1B7A4A"))
                    .padding(.horizontal)
                Text("بناءً على اختياراتك")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "2D4A3E").opacity(0.85))
                    .padding(.horizontal)
                VStack(alignment: .leading, spacing: 12) {
                    Text("الضروريات اليومية")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(hex: "2D4A3E"))
                    Text("هذه أساس يومك. إن فاتك يوم، الخطة تتكيف ولا نلوم.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "2D4A3E").opacity(0.85))
                    ForEach(store.dailyEssentials()) { item in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color(hex: "2ECC71"))
                            Text(item.titleAr).font(.system(size: 16))
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                VStack(alignment: .leading, spacing: 12) {
                    Text("إضافات اختيارية")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(hex: "2D4A3E"))
                    ForEach(store.optionalBonuses()) { item in
                        Text("• \(item.titleAr)").font(.system(size: 15))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                Text("لديك أيام راحة مضمونة. إذا غبت، نعدّل الهدف ولا نعيد العد من الصفر.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "2D4A3E").opacity(0.9))
                    .padding(.horizontal)
                Button(action: onContinue) {
                    Text("متابعة إلى الشجرة")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "1B7A4A"), in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
            }
            .padding(.vertical, 24)
        }
        .background(LinearGradient(colors: [Color(hex: "F0F7F4"), Color(hex: "E8F5E9")], startPoint: .top, endPoint: .bottom))
        .navigationBarTitleDisplayMode(.inline)
    }
}

@available(*, deprecated, message: "Replaced by PrayerTrackingView (Tree) as the daily hub")
struct WorshipPathDailyView: View {
    @ObservedObject var store: WorshipPathStore
    @State private var showPlan = false
    private var pathGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "F0F7F4"), Color(hex: "E8F5E9"), Color(hex: "F5F5F5")], startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.system(size: 15))
                        .foregroundStyle(Color(hex: "2D4A3E").opacity(0.9))
                    Text("مسيرتك اليوم")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(hex: "1B7A4A"))
                }
                .padding(.horizontal)
                .padding(.top, 16)
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(levelNameAr(store.progress.currentLevel))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(hex: "1B7A4A"))
                        Text("\(store.progress.streakDays) أيام على المسيرة")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "2D4A3E").opacity(0.9))
                    }
                    Spacer()
                    ProgressView(value: store.progress.levelProgress)
                        .tint(Color(hex: "2ECC71"))
                        .frame(width: 80)
                }
                .padding()
                .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                HStack(spacing: 8) {
                    Text("تركيز الأسبوع:").font(.system(size: 14, weight: .medium)).foregroundStyle(Color(hex: "2D4A3E").opacity(0.8))
                    Text(store.weeklyFocusAr()).font(.system(size: 14)).foregroundStyle(Color(hex: "1B7A4A"))
                }
                .padding(.horizontal)
                essentialsSection
                bonusesSection
            }
            .padding(.bottom, 30)
        }
        .background(pathGradient)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("خطتي") { showPlan = true }
                    .foregroundStyle(Color(hex: "1B7A4A"))
            }
        }
        .sheet(isPresented: $showPlan) {
            NavigationStack {
                WorshipPathPlanView(store: store, onContinue: { showPlan = false })
                    .toolbar { ToolbarItem(placement: .cancellationAction) { Button("إغلاق") { showPlan = false } } }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE، d MMMM"
        f.locale = Locale(identifier: "ar")
        return f.string(from: Date())
    }

    private func levelNameAr(_ level: PathLevel) -> String {
        switch level {
        case .seeds: return "البذور"
        case .roots: return "الجذور"
        case .growth: return "النمو"
        case .steadfast: return "الثبات"
        case .blossom: return "الإيناع"
        }
    }

    private var essentialsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("الضروريات اليومية")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(hex: "2D4A3E"))
                .padding(.horizontal)
            let todayLog = store.log()
            let completedTypes = Set(todayLog.actions.map(\.type))
            ForEach(store.dailyEssentials()) { item in
                let done = completedTypes.contains(item.actionType)
                Button {
                    if !done { store.addAction(item.actionType) }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: done ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(done ? Color(hex: "2ECC71") : Color(hex: "1B7A4A"))
                        Text(item.titleAr)
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "2D4A3E"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .disabled(done)
                .buttonStyle(.plain)
                .background(Color.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
    }

    private var bonusesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("إضافات اختيارية")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(hex: "2D4A3E").opacity(0.9))
                .padding(.horizontal)
            let todayLog = store.log()
            let completedTypes = Set(todayLog.actions.map(\.type))
            ForEach(store.optionalBonuses()) { item in
                if let type = item.actionType {
                    let done = completedTypes.contains(type)
                    Button {
                        if !done { store.addAction(type) }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: done ? "checkmark.circle" : "plus.circle")
                                .foregroundStyle(done ? Color(hex: "2ECC71") : Color(hex: "1B7A4A").opacity(0.8))
                            Text(item.titleAr)
                                .font(.system(size: 15))
                                .foregroundStyle(Color(hex: "2D4A3E").opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                    }
                    .disabled(done)
                    .buttonStyle(.plain)
                    .background(Color.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal)
        }
    }
}
