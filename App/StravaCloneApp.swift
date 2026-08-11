import SwiftUI
import SwiftData

@main
struct StravaCloneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Activity.self, RoutePoint.self])
    }
}
