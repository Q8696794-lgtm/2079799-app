import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var currentScreen: AppScreen = .loading

    var body: some View {
        ZStack {
            switch currentScreen {
            case .loading:
                Color(red: 0.06, green: 0.04, blue: 0.12)
                    .ignoresSafeArea()
                    .onAppear {
                        ImageCacheService.shared.preloadImages(urls: Deity.allDeities.map(\.heroImageURL))
                        determineScreen()
                    }

            case .welcome:
                WelcomeView {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .deitySelection
                    }
                }
                .transition(.opacity)

            case .deitySelection:
                DeitySelectionView { selectedIDs in
                    appState.selectDeities(selectedIDs)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .main
                    }
                }
                .transition(.opacity)

            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: currentScreen)
    }

    private func determineScreen() {
        if appState.hasCompletedOnboarding && !appState.selectedDeityIDs.isEmpty {
            currentScreen = .main
        } else {
            currentScreen = .welcome
        }
    }
}

enum AppScreen: Equatable {
    case loading
    case welcome
    case deitySelection
    case main
}
