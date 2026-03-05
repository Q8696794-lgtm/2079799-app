import SwiftUI

struct MeditationListView: View {
    let deity: Deity
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationService.self) private var loc
    @State private var selectedTrack: MeditationTrack?
    @State private var glowPhase = false

    private let goldLight = Color(red: 1, green: 0.85, blue: 0.4)
    private let goldDark = Color(red: 0.85, green: 0.65, blue: 0.2)

    private var tracks: [MeditationTrack] {
        MeditationTrack.tracks(for: deity.id)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        deityMeditationHeader
                            .padding(.bottom, 28)

                        VStack(spacing: 14) {
                            ForEach(tracks) { track in
                                NavigationLink(value: track.id) {
                                    trackCard(track)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)

                        meditationTip
                            .padding(.horizontal, 16)
                            .padding(.bottom, 60)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(meditationPrayerTitle)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(goldLight)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(loc.t(.done)) { dismiss() }
                        .foregroundStyle(goldLight)
                }
            }
            .navigationDestination(for: String.self) { trackID in
                if let track = tracks.first(where: { $0.id == trackID }) {
                    MeditationPlayerView(track: track, deity: deity)
                }
            }
        }
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.04, green: 0.02, blue: 0.10), location: 0),
                    .init(color: deity.primaryColor.opacity(0.10), location: 0.5),
                    .init(color: Color(red: 0.04, green: 0.02, blue: 0.10), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(deity.primaryColor.opacity(glowPhase ? 0.08 : 0.03))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: -100)
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        glowPhase = true
                    }
                }
        }
    }

    private var deityMeditationHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [deity.primaryColor.opacity(0.25), deity.primaryColor.opacity(0.03)],
                            center: .center, startRadius: 0, endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                Color.clear
                    .frame(width: 80, height: 100)
                    .overlay {
                        Image(deity.heroImageAsset)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 12))
                    .shadow(color: deity.primaryColor.opacity(0.4), radius: 16)
            }
            .padding(.top, 16)

            Text(deity.localizedName(for: loc.currentLanguage))
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(goldLight)

            Text(meditationSubtitle)
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func trackCard(_ track: MeditationTrack) -> some View {
        HStack(spacing: 14) {
            Image(systemName: track.icon)
                .font(.system(size: 22))
                .foregroundStyle(deity.secondaryColor)
                .frame(width: 48, height: 48)
                .background(deity.primaryColor.opacity(0.15))
                .clipShape(.rect(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(track.localizedName(for: loc.currentLanguage))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(track.localizedDesc(for: loc.currentLanguage))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(2)
            }

            Spacer()

            VStack(spacing: 4) {
                Text("\(track.durationMinutes)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(goldLight)
                Text(minLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                    .textCase(.uppercase)
            }

            Image(systemName: "play.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(deity.primaryColor.opacity(0.7))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.06), lineWidth: 0.5)
                )
        )
    }

    private var meditationTip: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow.opacity(0.7))
                Text(tipTitle)
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundStyle(goldLight)
            }

            Text(tipContent)
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.5))
                .lineSpacing(4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(goldDark.opacity(0.15), lineWidth: 0.5)
                )
        )
    }

    private var meditationPrayerTitle: String {
        switch loc.currentLanguage {
        case .english: return "Meditation & Prayer"
        case .chinese: return "冥想与祈祷"
        case .hindi: return "ध्यान और प्रार्थना"
        }
    }

    private var meditationSubtitle: String {
        let name = deity.localizedName(for: loc.currentLanguage)
        switch loc.currentLanguage {
        case .english: return "Choose a meditation to connect with \(name)'s divine energy"
        case .chinese: return "选择一种冥想方式与\(name)的神圣能量连接"
        case .hindi: return "\(name) की दिव्य ऊर्जा से जुड़ने के लिए ध्यान चुनें"
        }
    }

    private var minLabel: String {
        switch loc.currentLanguage {
        case .english: return "min"
        case .chinese: return "分钟"
        case .hindi: return "मिनट"
        }
    }

    private var tipTitle: String {
        switch loc.currentLanguage {
        case .english: return "Meditation Tips"
        case .chinese: return "冥想提示"
        case .hindi: return "ध्यान सुझाव"
        }
    }

    private var tipContent: String {
        switch loc.currentLanguage {
        case .english: return "Find a quiet space, sit comfortably, and close your eyes. Focus on the sacred sound and let your mind settle into stillness. Follow the breathing guide for deeper relaxation."
        case .chinese: return "找一个安静的地方，舒适地坐下，闭上双眼。专注于神圣的声音，让心灵沉入寂静。跟随呼吸引导以获得更深的放松。"
        case .hindi: return "एक शांत स्थान खोजें, आराम से बैठें, और अपनी आँखें बंद करें। पवित्र ध्वनि पर ध्यान केंद्रित करें और अपने मन को शांति में स्थिर होने दें। गहन विश्राम के लिए श्वास मार्गदर्शिका का पालन करें।"
        }
    }
}
