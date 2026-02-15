import SwiftUI

@main
struct HedayaApp: App {
    @StateObject private var prayerTracker = PrayerTrackingStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(prayerTracker)
        }
    }
}
