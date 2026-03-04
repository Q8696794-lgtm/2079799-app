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

                        dailyActivitySection
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
        VStack(spacing: 16) {
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
                HStack(spacing: 4) {
                    Image(systemName: appState.progress.level.icon)
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                    Text(appState.progress.level.localizedName(for: loc.currentLanguage))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                if let next = nextLevel {
                    HStack(spacing: 4) {
                        Text(next.localizedName(for: loc.currentLanguage))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.5))
                        Image(systemName: next.icon)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
            }

            if let next = nextLevel {
                let pointsNeeded = punyaForLevel(next) - appState.progress.punyaPoints
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.cyan.opacity(0.7))
                    Text(pointsToNextLevelText(pointsNeeded))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                    Text(maxLevelText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                }
            }

            levelMilestonesView
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

    private var levelMilestonesView: some View {
        VStack(spacing: 8) {
            ForEach(DevotionLevel.allCases, id: \.self) { level in
                let reached = appState.progress.punyaPoints >= punyaForLevel(level)
                HStack(spacing: 10) {
                    Image(systemName: reached ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14))
                        .foregroundStyle(reached ? Color(red: 1, green: 0.85, blue: 0.4) : .white.opacity(0.2))

                    Image(systemName: level.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(reached ? Color(red: 1, green: 0.85, blue: 0.4) : .white.opacity(0.3))
                        .frame(width: 20)

                    Text(level.localizedName(for: loc.currentLanguage))
                        .font(.system(size: 12, weight: reached ? .bold : .medium))
                        .foregroundStyle(reached ? .white : .white.opacity(0.35))

                    Spacer()

                    Text("\(punyaForLevel(level))")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(reached ? Color(red: 1, green: 0.85, blue: 0.4).opacity(0.7) : .white.opacity(0.2))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.03))
        )
    }

    private func punyaForLevel(_ level: DevotionLevel) -> Int {
        switch level {
        case .shishya: return 0
        case .sadhak: return 500
        case .upasak: return 2000
        case .bhakt: return 5000
        case .paramBhakt: return 15000
        }
    }

    private func pointsToNextLevelText(_ points: Int) -> String {
        switch loc.currentLanguage {
        case .english: return "\(points) Punya to next level"
        case .chinese: return "距下一级还需 \(points) 功德"
        case .hindi: return "अगले स्तर के लिए \(points) पुण्य"
        }
    }

    private var maxLevelText: String {
        switch loc.currentLanguage {
        case .english: return "Maximum devotion level reached!"
        case .chinese: return "已达到最高修行等级！"
        case .hindi: return "अधिकतम भक्ति स्तर प्राप्त!"
        }
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

            let stats: [(String, String, String, Color)] = [
                (loc.t(.darshanStreak), "\(appState.progress.dailyDarshanStreak)", "flame.fill", .orange),
                (loc.t(.totalDarshanLabel), "\(appState.progress.totalDarshanCount)", "eye.fill", .blue),
                (loc.t(.mantrasChantedLabel), "\(appState.progress.totalMantrasChanted)", "music.note.list", .purple),
                (loc.t(.malasComplete), "\(appState.progress.totalMantrasChanted / 108)", "circle.hexagongrid.fill", .cyan),
                (totalAartiLabel, "\(appState.progress.totalAartiCount)", "flame.circle.fill", .orange),
                (totalPunyaLabel, "\(appState.progress.punyaPoints)", "sparkles", Color(red: 1, green: 0.85, blue: 0.4)),
            ]

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(stats, id: \.0) { stat in
                    VStack(spacing: 8) {
                        Image(systemName: stat.2)
                            .font(.system(size: 20))
                            .foregroundStyle(stat.3)
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

    private var totalAartiLabel: String {
        switch loc.currentLanguage {
        case .english: return "Total Aarti"
        case .chinese: return "灯祭次数"
        case .hindi: return "कुल आरती"
        }
    }

    private var totalPunyaLabel: String {
        switch loc.currentLanguage {
        case .english: return "Total Punya"
        case .chinese: return "总功德"
        case .hindi: return "कुल पुण्य"
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
                (firstAartiLabel, "flame.circle.fill", appState.progress.totalAartiCount >= 1),
                (loc.t(.sadhakLevel), "flame.fill", appState.progress.level.rawValue != "Shishya"),
                (loc.t(.thirtyDayStreak), "flame.fill", appState.progress.dailyDarshanStreak >= 30),
                (aarti10Label, "flame.circle.fill", appState.progress.totalAartiCount >= 10),
                (punya1000Label, "sparkles", appState.progress.punyaPoints >= 1000),
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

    private var dailyActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(todayActivityTitle)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

            HStack(spacing: 12) {
                dailyActivityItem(
                    icon: appState.hasDoneDarshanToday() ? "checkmark.circle.fill" : "circle",
                    title: loc.t(.dailyDarshan),
                    subtitle: "+10",
                    done: appState.hasDoneDarshanToday(),
                    color: .blue
                )
                dailyActivityItem(
                    icon: appState.hasDoneAartiToday() ? "checkmark.circle.fill" : "circle",
                    title: loc.t(.virtualAarti),
                    subtitle: "+15",
                    done: appState.hasDoneAartiToday(),
                    color: .orange
                )
            }
        }
    }

    private func dailyActivityItem(icon: String, title: String, subtitle: String, done: Bool, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(done ? .green : .white.opacity(0.2))
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(done ? .white : .white.opacity(0.4))
            Text(done ? doneLabel : subtitle)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(done ? .green : color.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(done ? color.opacity(0.08) : .white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(done ? .green.opacity(0.3) : .white.opacity(0.05), lineWidth: 0.5)
                )
        )
    }

    private var todayActivityTitle: String {
        switch loc.currentLanguage {
        case .english: return "Today's Practice"
        case .chinese: return "今日修行"
        case .hindi: return "आज की साधना"
        }
    }

    private var doneLabel: String {
        switch loc.currentLanguage {
        case .english: return "Done"
        case .chinese: return "已完成"
        case .hindi: return "पूर्ण"
        }
    }

    private var firstAartiLabel: String {
        switch loc.currentLanguage {
        case .english: return "First Aarti"
        case .chinese: return "首次灯祭"
        case .hindi: return "प्रथम आरती"
        }
    }

    private var aarti10Label: String {
        switch loc.currentLanguage {
        case .english: return "10 Aartis"
        case .chinese: return "10次灯祭"
        case .hindi: return "10 आरती"
        }
    }

    private var punya1000Label: String {
        switch loc.currentLanguage {
        case .english: return "1000 Punya"
        case .chinese: return "1000功德"
        case .hindi: return "1000 पुण्य"
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
