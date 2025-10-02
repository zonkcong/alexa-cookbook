import SwiftUI

@main
struct ReelsGlassProtoApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var motionManager = MotionManager()

    var body: some Scene {
        WindowGroup {
            ReelsRootView()
                .environmentObject(themeManager)
                .environmentObject(motionManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
