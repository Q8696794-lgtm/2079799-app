import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(LocalizationService.self) private var loc
    @State private var showResetAlert = false
    @State private var showLanguagePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.04, blue: 0.12)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader
                            .padding(.top, 8)

                        levelProgressCard
                            .padding(.horizontal, 16)

                        selectedDeitiesSection
                            .padding(.horizontal, 16)

                        statsGridSection
                            .padding(.horizontal, 16)

                        achievementsSection
                            .padding(.horizontal, 16)

                        settingsSection
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(loc.t(.profile))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert(loc.t(.resetProgress), isPresented: $showResetAlert) {
                Button(loc.t(.cancel), role: .cancel) {}
                Button(loc.t(.reset), role: .destructive) {
                    appState.progress = UserProgress()
                }
            } message: {
                Text(loc.t(.resetWarning))
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerSheet()
                    .presentationDetents([.height(280)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func deityName(_ deity: Deity) -> String {
        switch loc.currentLanguage {
        case .english: return deity.nameEnglish
        case .chinese: return deity.nameChinese
        case .hindi: return deity.nameHindi
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.3), .clear],
                            center: .center, startRadius: 0, endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: appState.progress.level.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
            }

            VStack(spacing: 4) {
                Text(loc.t(.devotee))
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Image(systemName: appState.progress.level.icon)
                        .font(.system(size: 12))
                    Text(appState.progress.level.localizedName(for: loc.currentLanguage))
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
            }
        }
    }

    private var levelProgressCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text(loc.t(.devotionProgress))
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                Spacer()
                Text("\(appState.progress.punyaPoints) \(loc.t(.punya))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white.opacity(0.1))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.85, green: 0.65, blue: 0.2)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * appState.progress.nextLevelProgress, height: 12)
                }
            }
            .frame(height: 12)

            HStack {
                Text(appState.progress.level.localizedName(for: loc.currentLanguage))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                if let nextLevel = nextLevel {
                    Text(nextLevel.localizedName(for: loc.currentLanguage))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.2), lineWidth: 0.5)
                )
        )
    }

    private var nextLevel: DevotionLevel? {
        let all = DevotionLevel.allCases
        guard let index = all.firstIndex(of: appState.progress.level),
              index + 1 < all.count else { return nil }
        return all[index + 1]
    }

    private var selectedDeitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.t(.yourGuardians))
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

            HStack(spacing: 12) {
                ForEach(appState.selectedDeities) { deity in
                    VStack(spacing: 8) {
                        Text(deity.symbol)
                            .font(.system(size: 36))
                            .frame(width: 64, height: 64)
                            .background(deity.primaryColor.opacity(0.2))
                            .clipShape(Circle())

                        Text(deityName(deity))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)

                        if deity.id == appState.primaryDeityID {
                            Text(loc.t(.primary))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.04))
            )
        }
    }

    private var statsGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.t(.statistics))
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

            let stats: [(String, String, String)] = [
                (loc.t(.darshanStreak), "\(appState.progress.dailyDarshanStreak)", "flame.fill"),
                (loc.t(.totalDarshanLabel), "\(appState.progress.totalDarshanCount)", "eye.fill"),
                (loc.t(.mantrasChantedLabel), "\(appState.progress.totalMantrasChanted)", "music.note.list"),
                (loc.t(.malasComplete), "\(appState.progress.totalMantrasChanted / 108)", "circle.hexagongrid.fill"),
            ]

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(stats, id: \.0) { stat in
                    VStack(spacing: 8) {
                        Image(systemName: stat.2)
                            .font(.system(size: 20))
                            .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                        Text(stat.1)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        Text(stat.0)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.white.opacity(0.04))
                    )
                }
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.t(.achievements))
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

            let achievements: [(String, String, Bool)] = [
                (loc.t(.firstDarshan), "sun.max.fill", appState.progress.totalDarshanCount >= 1),
                (loc.t(.sevenDayStreak), "flame.fill", appState.progress.dailyDarshanStreak >= 7),
                (loc.t(.mantras108), "music.note", appState.progress.totalMantrasChanted >= 108),
                (loc.t(.mantras1000), "music.note.list", appState.progress.totalMantrasChanted >= 1000),
                (loc.t(.sadhakLevel), "flame.fill", appState.progress.level.rawValue != "Shishya"),
                (loc.t(.thirtyDayStreak), "flame.fill", appState.progress.dailyDarshanStreak >= 30),
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(achievements, id: \.0) { achievement in
                    VStack(spacing: 8) {
                        Image(systemName: achievement.1)
                            .font(.system(size: 24))
                            .foregroundStyle(achievement.2 ? Color(red: 1, green: 0.85, blue: 0.4) : .white.opacity(0.2))
                        Text(achievement.0)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(achievement.2 ? .white : .white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(achievement.2 ? Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.1) : .white.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(achievement.2 ? Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.3) : .clear, lineWidth: 0.5)
                            )
                    )
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.t(.settings))
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

            Button {
                showLanguagePicker = true
            } label: {
                HStack {
                    Image(systemName: "globe")
                    Text(loc.t(.language))
                    Spacer()
                    HStack(spacing: 6) {
                        Text(loc.currentLanguage.flag)
                        Text(loc.currentLanguage.displayName)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .opacity(0.4)
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(0.04))
                )
            }

            Button {
                showResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text(loc.t(.resetProgress))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .opacity(0.4)
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.red.opacity(0.8))
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(0.04))
                )
            }
        }
    }
}
