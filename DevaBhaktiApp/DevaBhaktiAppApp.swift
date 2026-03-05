import SwiftUI

@main
struct DevaBhaktiAppApp: App {
    @State private var appState = AppState()
    @State private var localizationService = LocalizationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(localizationService)
                .preferredColorScheme(.dark)
                .onAppear {
                    appState.loadFollowerCounts()
                }
        }
    }
}
