import SwiftUI

struct HymnPlayerView: View {
    let hymn: HymnTrack
    let deity: Deity
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationService.self) private var loc
    @State private var audioService = HymnAudioService()
    @State private var pulsePhase = false

    private let goldLight = Color(red: 1, green: 0.85, blue: 0.4)
    private let goldDark = Color(red: 0.85, green: 0.65, blue: 0.2)

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                albumArt
                    .padding(.bottom, 40)

                trackInfoSection
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)

                progressSection
                    .padding(.horizontal, 32)
                    .padding(.bottom, 28)

                controlButtons
                    .padding(.bottom, 16)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    audioService.stop()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .onAppear {
            if let url = hymn.audioURL {
                audioService.loadAndPlay(url: url)
            }
        }
        .onDisappear {
            audioService.stop()
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.04, green: 0.02, blue: 0.10), location: 0),
                    .init(color: deity.primaryColor.opacity(0.15), location: 0.4),
                    .init(color: Color(red: 0.06, green: 0.03, blue: 0.12), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(deity.primaryColor.opacity(pulsePhase ? 0.12 : 0.04))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(y: -80)
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        pulsePhase = true
                    }
                }
        }
    }

    private var albumArt: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [deity.primaryColor.opacity(0.3), deity.primaryColor.opacity(0.05)],
                        center: .center, startRadius: 0, endRadius: 100
                    )
                )
                .frame(width: 220, height: 220)

            Color.clear
                .frame(width: 140, height: 175)
                .overlay {
                    Image(deity.heroImageAsset)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 18))
                .shadow(color: deity.primaryColor.opacity(0.5), radius: 24)

            Circle()
                .stroke(goldLight.opacity(0.15), lineWidth: 1)
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(pulsePhase ? 360 : 0))
                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: pulsePhase)
        }
    }

    private var trackInfoSection: some View {
        VStack(spacing: 8) {
            Text(hymn.localizedName(for: loc.currentLanguage))
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(deity.localizedName(for: loc.currentLanguage))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(goldLight.opacity(0.7))

            Text(hymn.localizedDesc(for: loc.currentLanguage))
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 4)
        }
    }

    private var progressSection: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.1))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [goldLight, deity.primaryColor],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * audioService.progress, height: 4)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let fraction = max(0, min(1, value.location.x / geo.size.width))
                            audioService.seek(to: fraction)
                        }
                )
            }
            .frame(height: 4)

            HStack {
                Text(audioService.currentTimeString)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
                Text(audioService.remainingTimeString)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 48) {
            Button {
                let target = max(0, audioService.currentTime - 15)
                audioService.seek(to: target / max(1, audioService.duration))
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Button {
                if audioService.isPlaying || audioService.currentTime > 0 {
                    audioService.togglePlayPause()
                } else if let url = hymn.audioURL {
                    audioService.loadAndPlay(url: url)
                }
            } label: {
                Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [goldLight, goldDark],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: goldDark.opacity(0.4), radius: 12)
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: audioService.isPlaying)

            Button {
                let target = min(audioService.duration, audioService.currentTime + 15)
                audioService.seek(to: target / max(1, audioService.duration))
            } label: {
                Image(systemName: "goforward.15")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}
