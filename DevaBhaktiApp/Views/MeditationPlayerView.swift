import SwiftUI

struct MeditationPlayerView: View {
    let track: MeditationTrack
    let deity: Deity
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationService.self) private var loc
    @Environment(AppState.self) private var appState
    @State private var audioService = MeditationAudioService()
    @State private var lastAwardedMinute: Int = 0
    @State private var meritEarned: Int = 0
    @State private var breatheIn = false
    @State private var showCompletion = false
    @State private var pulsePhase = false

    private let goldLight = Color(red: 1, green: 0.85, blue: 0.4)
    private let goldDark = Color(red: 0.85, green: 0.65, blue: 0.2)

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                    .padding(.top, 8)

                Spacer()

                timerRing
                    .padding(.bottom, 32)

                breathingGuide
                    .padding(.bottom, 32)

                controlButtons
                    .padding(.bottom, 16)

                trackInfo
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }

            if showCompletion {
                completionOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    audioService.stopMeditation()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .onAppear {
            startBreathingAnimation()
        }
        .onDisappear {
            audioService.stopMeditation()
        }
        .onChange(of: audioService.isPlaying) { _, newValue in
            if !newValue && audioService.elapsedSeconds >= audioService.totalSeconds && audioService.totalSeconds > 0 {
                awardMeditationMerit()
                withAnimation(.spring(response: 0.5)) {
                    showCompletion = true
                }
            }
        }
        .onChange(of: audioService.elapsedSeconds) { _, newValue in
            let currentMinute = newValue / 60
            if currentMinute > lastAwardedMinute && currentMinute % 10 == 0 {
                let minutesToAward = currentMinute - lastAwardedMinute
                appState.recordMeditationTime(minutes: minutesToAward)
                meritEarned += (minutesToAward / 10) * 2
                lastAwardedMinute = currentMinute
            }
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.04, green: 0.02, blue: 0.10), location: 0),
                    .init(color: deity.primaryColor.opacity(0.12), location: 0.4),
                    .init(color: Color(red: 0.04, green: 0.02, blue: 0.10), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Canvas { context, size in
                for i in 0..<30 {
                    let seed = Double(i) * 137.508
                    let x = (sin(seed) * 0.5 + 0.5) * size.width
                    let baseY = (cos(seed * 0.7) * 0.5 + 0.5) * size.height
                    let y = baseY + (pulsePhase ? -8 : 8)
                    let r = 0.8 + sin(seed * 0.3) * 0.6
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)),
                        with: .color(goldLight.opacity(0.06))
                    )
                }
            }
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    pulsePhase = true
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Color.clear
                .frame(width: 64, height: 80)
                .overlay {
                    Image(deity.heroImageAsset)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 10))
                .shadow(color: deity.primaryColor.opacity(0.5), radius: 12)

            Text(track.localizedName(for: loc.currentLanguage))
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundStyle(goldLight)

            Text(deity.localizedName(for: loc.currentLanguage))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.06), lineWidth: 6)
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: audioService.progress)
                .stroke(
                    AngularGradient(
                        colors: [deity.primaryColor, goldLight, deity.secondaryColor, deity.primaryColor],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: audioService.progress)

            VStack(spacing: 8) {
                Text(audioService.remainingTimeString)
                    .font(.system(size: 44, weight: .thin, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                Text(remainingLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                    .textCase(.uppercase)
                    .tracking(2)
            }
        }
    }

    private var breathingGuide: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [deity.primaryColor.opacity(0.4), deity.primaryColor.opacity(0.05)],
                        center: .center, startRadius: 0, endRadius: 40
                    )
                )
                .frame(width: breatheIn ? 70 : 40, height: breatheIn ? 70 : 40)
                .animation(.easeInOut(duration: 4), value: breatheIn)

            Text(breatheIn ? breatheInText : breatheOutText)
                .font(.system(size: 13, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.5))
                .animation(.easeInOut(duration: 0.3), value: breatheIn)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 40) {
            Button {
                audioService.stopMeditation()
                audioService.elapsedSeconds = 0
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }

            Button {
                if !audioService.isPlaying && audioService.elapsedSeconds == 0 {
                    audioService.startMeditation(
                        frequency: track.frequency,
                        harmonicFrequency: track.harmonicFrequency,
                        durationMinutes: track.durationMinutes
                    )
                } else {
                    audioService.togglePlayPause()
                }
            } label: {
                Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(red: 0.06, green: 0.04, blue: 0.12))
                    .frame(width: 72, height: 72)
                    .background(
                        LinearGradient(
                            colors: [goldLight, goldDark],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: goldDark.opacity(0.4), radius: 12)
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: audioService.isPlaying)

            Button {
                audioService.stopMeditation()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
    }

    private var trackInfo: some View {
        Text(track.localizedDesc(for: loc.currentLanguage))
            .font(.system(size: 13, weight: .regular, design: .serif))
            .foregroundStyle(.white.opacity(0.4))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 56))
                    .foregroundStyle(goldLight)
                    .symbolEffect(.bounce, value: showCompletion)

                Text(meditationCompleteTitle)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                Text("\(track.durationMinutes) \(minutesLabel)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(goldLight)

                if meritEarned > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                        Text("+\(meritEarned) \(punyaLabel)")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.yellow)
                    .padding(.top, 4)
                }

                Text(meditationCompleteMessage)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button {
                    dismiss()
                } label: {
                    Text(loc.t(.namaste))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color(red: 0.06, green: 0.04, blue: 0.12))
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [goldLight, goldDark],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 25))
                }
                .padding(.top, 8)
            }
        }
        .transition(.opacity)
    }

    private func awardMeditationMerit() {
        let totalMinutes = audioService.elapsedSeconds / 60
        let remainingMinutes = totalMinutes - lastAwardedMinute
        if remainingMinutes > 0 {
            appState.recordMeditationTime(minutes: remainingMinutes)
            meritEarned += (remainingMinutes / 10) * 2
        }
    }

    private func startBreathingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            Task { @MainActor in
                breatheIn.toggle()
            }
        }
        breatheIn = true
    }

    private var remainingLabel: String {
        switch loc.currentLanguage {
        case .english: return "remaining"
        case .chinese: return "剩余"
        case .hindi: return "शेष"
        }
    }

    private var breatheInText: String {
        switch loc.currentLanguage {
        case .english: return "Breathe in..."
        case .chinese: return "吸气..."
        case .hindi: return "श्वास लें..."
        }
    }

    private var breatheOutText: String {
        switch loc.currentLanguage {
        case .english: return "Breathe out..."
        case .chinese: return "呼气..."
        case .hindi: return "श्वास छोड़ें..."
        }
    }

    private var minutesLabel: String {
        switch loc.currentLanguage {
        case .english: return "minutes of meditation"
        case .chinese: return "分钟冥想"
        case .hindi: return "मिनट ध्यान"
        }
    }

    private var meditationCompleteTitle: String {
        switch loc.currentLanguage {
        case .english: return "Meditation Complete"
        case .chinese: return "冥想完成"
        case .hindi: return "ध्यान पूर्ण"
        }
    }

    private var punyaLabel: String {
        switch loc.currentLanguage {
        case .english: return "Punya"
        case .chinese: return "功德"
        case .hindi: return "पुण्य"
        }
    }

    private var meditationCompleteMessage: String {
        let name = deity.localizedName(for: loc.currentLanguage)
        switch loc.currentLanguage {
        case .english: return "Your meditation with \(name) has brought you closer to inner peace. May this serenity stay with you."
        case .chinese: return "你与\(name)的冥想让你更接近内心的平静。愿这份宁静与你同在。"
        case .hindi: return "\(name) के साथ आपके ध्यान ने आपको आंतरिक शांति के करीब लाया है। यह शांति आपके साथ रहे।"
        }
    }
}
