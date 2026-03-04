import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @Environment(LocalizationService.self) private var loc

    var body: some View {
        TabView {
            Tab(loc.t(.darshan), systemImage: "sun.max.fill") {
                DarshanView()
            }

            Tab(loc.t(.mantras), systemImage: "music.note.list") {
                MantraView()
            }

            Tab(loc.t(.divination), systemImage: "sparkles.rectangle.stack") {
                DivinationView()
            }

            Tab(loc.t(.calendar), systemImage: "calendar") {
                CalendarView()
            }

            Tab(loc.t(.profile), systemImage: "person.fill") {
                ProfileView()
            }
        }
        .id(loc.currentLanguage)
        .tint(Color(red: 0.85, green: 0.65, blue: 0.2))
    }
}
