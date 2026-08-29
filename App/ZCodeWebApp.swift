import SwiftUI
import UserNotifications

@main
struct ZCodeWebApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView(settings: settings)
        }
    }
}
