import SwiftUI
import CoreText

@main
struct HedayaApp: App {
    @StateObject private var prayerTracker = PrayerTrackingStore()

    init() {
        if let url = Bundle.main.url(forResource: "AmiriQuran", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(prayerTracker)
        }
    }
}
