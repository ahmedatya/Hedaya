import SwiftUI
import CoreText

@main
struct HedayaApp: App {
    @StateObject private var prayerTracker = PrayerTrackingStore()
    @AppStorage("hedaya_appearance") private var appearanceMode: Int = 0

    init() {
        if let url = Bundle.main.url(forResource: "AmiriQuran", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    private var preferredScheme: ColorScheme? {
        switch appearanceMode {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(prayerTracker)
                .preferredColorScheme(preferredScheme)
        }
    }
}
