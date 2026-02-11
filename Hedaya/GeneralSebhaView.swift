import SwiftUI
import UserNotifications

// MARK: - Constants
private let maxCounterValue = 1_000_000
private let goalRange = 1...10_000
private let goalPresets: [Int] = [33, 100, 1000]

/// Popular short zekr for the general sebha picker
struct PopularZekrItem: Identifiable {
    let id = UUID()
    let text: String
    let recommendedCount: Int
}

private let popularZekrList: [PopularZekrItem] = [
    PopularZekrItem(text: "سُبْحَانَ اللَّهِ", recommendedCount: 33),
    PopularZekrItem(text: "الْحَمْدُ لِلَّهِ", recommendedCount: 33),
    PopularZekrItem(text: "اللَّهُ أَكْبَرُ", recommendedCount: 33),
    PopularZekrItem(text: "لَا إِلَٰهَ إِلَّا اللَّهُ", recommendedCount: 100),
    PopularZekrItem(text: "أَسْتَغْفِرُ اللَّهَ", recommendedCount: 100),
    PopularZekrItem(text: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ", recommendedCount: 100),
    PopularZekrItem(text: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ", recommendedCount: 100),
    PopularZekrItem(text: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ", recommendedCount: 100),
]

// MARK: - General Sebha View
struct GeneralSebhaView: View {
    @AppStorage("sebha_count") private var storedCount: Int = 0
    @AppStorage("sebha_max_goal") private var storedMaxGoal: Int = 0
    @AppStorage("sebha_recommend_mode") private var recommendMode: Bool = false
    @AppStorage("sebha_zekr_index") private var selectedZekrIndex: Int = 0
    @AppStorage("sebha_simple_counter") private var useSimpleCounter: Bool = true

    @State private var count: Int = 0
    @State private var showPulse: Bool = false
    @State private var showSettings: Bool = false
    @State private var showMaxReachedAlert: Bool = false
    @State private var notificationPermissionRequested: Bool = false
    /// Local goal value in settings sheet; only written to storedMaxGoal on "تم" so presets stick.
    @State private var settingsGoalValue: Int = 100

    private let sebhaColors: [Color] = [Color(hex: "1B7A4A"), Color(hex: "2ECC71")]

    private var effectiveMaxGoal: Int? {
        let g = storedMaxGoal
        return g > 0 ? g : nil
    }

    private var progress: Double {
        guard let max = effectiveMaxGoal, max > 0 else { return 0 }
        return min(1.0, Double(count) / Double(max))
    }

    private var selectedZekr: PopularZekrItem {
        let idx = min(selectedZekrIndex, popularZekrList.count - 1)
        return popularZekrList[max(0, idx)]
    }

    var body: some View {
        ZStack {
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

            VStack(spacing: 0) {
                // Header with settings
                HStack {
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(sebhaColors[0])
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }

                // Recommend mode suggestion
                if recommendMode && !useSimpleCounter {
                    VStack(spacing: 6) {
                        Text("الذكر المقترح")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(hex: "2D4A3E"))
                        Text(selectedZekr.text)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(sebhaColors[0])
                            .multilineTextAlignment(.center)
                        Text("مقترح: \(selectedZekr.recommendedCount)")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }

                Spacer()

                // Counter display
                VStack(spacing: 8) {
                    Text("\(count)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(sebhaColors[0])
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: count)

                    if let max = effectiveMaxGoal {
                        Text("من \(max)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color(hex: "2D4A3E"))
                    } else {
                        Text("اضغط للعد")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }

                // Progress ring when goal is set
                if effectiveMaxGoal != nil {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 6)
                            .frame(width: 130, height: 130)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(colors: sebhaColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 130, height: 130)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: progress)
                    }
                    .padding(.top, 16)
                }

                // Tap button
                ZStack {
                    Circle()
                        .fill(sebhaColors[0].opacity(0.15))
                        .frame(width: showPulse ? 110 : 90, height: showPulse ? 110 : 90)
                        .animation(.easeOut(duration: 0.25), value: showPulse)

                    Circle()
                        .fill(.white)
                        .frame(width: 90, height: 90)
                        .shadow(color: sebhaColors[0].opacity(0.35), radius: 10, x: 0, y: 4)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(colors: sebhaColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 3
                                )
                        )
                        .overlay(
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(LinearGradient(colors: sebhaColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .scaleEffect(showPulse ? 0.92 : 1.0)
                        .animation(.easeOut(duration: 0.15), value: showPulse)
                }
                .onTapGesture {
                    incrementCount()
                }
                .padding(.top, 28)

                // Reset button
                Button(action: resetCounter) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("إعادة الصفر")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(sebhaColors[0])
                }
                .padding(.top, 24)

                Spacer().frame(height: 40)
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
        .onAppear {
            count = storedCount
            if storedMaxGoal > 0 {
                requestNotificationPermissionIfNeeded()
            }
        }
        .onChange(of: count) { newValue in
            storedCount = newValue
            if let max = effectiveMaxGoal, newValue >= max {
                triggerGoalReached()
            }
        }
        .sheet(isPresented: $showSettings) {
            sebhaSettingsSheet
        }
        .onChange(of: showSettings) { isShowing in
            if isShowing {
                settingsGoalValue = storedMaxGoal > 0 ? min(max(goalRange.lowerBound, storedMaxGoal), goalRange.upperBound) : 100
            }
        }
        .alert("تم الوصول للهدف! 🎉", isPresented: $showMaxReachedAlert) {
            Button("حسناً", role: .cancel) {}
        } message: {
            Text("بلغت \(count) تسبيحة. بارك الله فيك.")
        }
    }

    // MARK: - Settings Sheet
    private var sebhaSettingsSheet: some View {
        NavigationStack {
            Form {
                Section("الحد الأقصى للذكر") {
                    Toggle("تفعيل هدف (إشعار عند الوصول)", isOn: Binding(
                        get: { effectiveMaxGoal != nil },
                        set: { enabled in
                            if enabled {
                                storedMaxGoal = min(max(goalRange.lowerBound, settingsGoalValue), goalRange.upperBound)
                                requestNotificationPermissionIfNeeded()
                            } else {
                                storedMaxGoal = 0
                            }
                        }
                    ))
                    if effectiveMaxGoal != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("اختيار سريع")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                            HStack(spacing: 10) {
                                ForEach(goalPresets, id: \.self) { preset in
                                    presetButton(preset)
                                }
                            }
                            HStack {
                                Text("العدد")
                                Spacer()
                                Text("\(settingsGoalValue)")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(sebhaColors[0])
                            }
                            Slider(
                                value: Binding(
                                    get: { Double(settingsGoalValue) },
                                    set: { settingsGoalValue = Int($0.rounded()) }
                                ),
                                in: Double(goalRange.lowerBound)...Double(goalRange.upperBound),
                                step: 1
                            )
                        }
                    }
                }

                Section("وضع العد") {
                    Picker("النوع", selection: $useSimpleCounter) {
                        Text("سبحة فقط (عدّاد)").tag(true)
                        Text("اختيار ذكر من القائمة").tag(false)
                    }
                    .pickerStyle(.menu)

                    if !useSimpleCounter {
                        Picker("الذكر", selection: $selectedZekrIndex) {
                            ForEach(Array(popularZekrList.enumerated()), id: \.element.id) { index, item in
                                Text(item.text).tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                Section("اقتراح الذكر") {
                    Toggle("وضع الاقتراح (عرض ذكر مقترح)", isOn: $recommendMode)
                }
            }
            .navigationTitle("إعدادات السبحة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("تم") {
                        if effectiveMaxGoal != nil {
                            storedMaxGoal = min(max(goalRange.lowerBound, settingsGoalValue), goalRange.upperBound)
                        }
                        showSettings = false
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    private func presetButton(_ preset: Int) -> some View {
        Button {
            settingsGoalValue = preset
        } label: {
            Text("\(preset)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(settingsGoalValue == preset ? .white : sebhaColors[0])
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(settingsGoalValue == preset ? sebhaColors[0] : sebhaColors[0].opacity(0.15))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions
    private func incrementCount() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        showPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showPulse = false
        }

        guard count < maxCounterValue else { return }
        count += 1
    }

    private func resetCounter() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        withAnimation(.easeInOut(duration: 0.25)) {
            count = 0
        }
    }

    private func requestNotificationPermissionIfNeeded() {
        guard !notificationPermissionRequested else { return }
        notificationPermissionRequested = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func triggerGoalReached() {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        showMaxReachedAlert = true
        SebhaNotification.scheduleGoalReachedNotification(count: count)
    }
}

// MARK: - Local notification helper
enum SebhaNotification {
    static func scheduleGoalReachedNotification(count: Int) {
        let content = UNMutableNotificationContent()
        content.title = "تم الوصول للهدف! 🎉"
        content.body = "بلغت \(count) تسبيحة. بارك الله فيك."
        content.sound = .default
        let request = UNNotificationRequest(identifier: "sebha-goal-\(UUID().uuidString)", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false))
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    NavigationStack {
        GeneralSebhaView()
    }
}
