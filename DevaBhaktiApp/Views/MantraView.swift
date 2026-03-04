import SwiftUI

struct MantraView: View {
    @Environment(AppState.self) private var appState
    @Environment(LocalizationService.self) private var loc
    @State private var selectedMantra: Mantra?
    @State private var showChanting = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.04, blue: 0.12)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        totalChantedCard
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        ForEach(appState.selectedDeities) { deity in
                            deityMantraSection(deity)
                        }
                    }
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(loc.t(.mantras))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedMantra) { mantra in
                MalaChantingView(mantra: mantra)
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

    private var totalChantedCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.85, blue: 0.4), Color(red: 0.85, green: 0.65, blue: 0.2)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(loc.t(.totalMantrasChanted))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                Text("\(appState.progress.totalMantrasChanted)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(loc.t(.lifetime))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                Text("\(appState.progress.totalMantrasChanted / 108) \(loc.t(.malas))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.15, green: 0.10, blue: 0.25), Color(red: 0.10, green: 0.07, blue: 0.18)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.2), lineWidth: 0.5)
                )
        )
    }

    private func deityMantraSection(_ deity: Deity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(deity.symbol)
                    .font(.system(size: 24))
                Text(deityName(deity))
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
            }
            .padding(.horizontal, 16)

            ForEach(deity.mantras) { mantra in
                Button {
                    selectedMantra = mantra
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mantra.sanskrit)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)

                        Text(mantra.transliteration)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(deity.primaryColor)

                        Text(mantra.localizedTranslation(for: loc.currentLanguage))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.white.opacity(0.5))

                        HStack {
                            Label("\(mantra.repetitions) \(loc.t(.reps))", systemImage: "repeat")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.4))
                            Spacer()
                            HStack(spacing: 4) {
                                Text(loc.t(.chant))
                                    .font(.system(size: 13, weight: .semibold))
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
        }
    }
}

struct MalaChantingView: View {
    let mantra: Mantra
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Environment(LocalizationService.self) private var loc
    @State private var count: Int = 0
    @State private var isChanting = false
    @State private var beadPulse = false
    @State private var showCompletion = false

    private let totalBeads = 108
    private let beadColumns = [GridItem](repeating: GridItem(.flexible(), spacing: 4), count: 9)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.04, green: 0.03, blue: 0.08)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Text(mantra.sanskrit)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    Text(mantra.transliteration)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

                    malaGrid
                        .padding(.horizontal, 16)

                    counterDisplay

                    chantButton
                        .padding(.horizontal, 40)

                    Spacer()
                }

                if showCompletion {
                    completionOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(loc.t(.done)) {
                        if count > 0 {
                            appState.recordMantraChant(count: count)
                        }
                        dismiss()
                    }
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                }
            }
        }
    }

    private var malaGrid: some View {
        LazyVGrid(columns: beadColumns, spacing: 4) {
            ForEach(0..<totalBeads, id: \.self) { index in
                Circle()
                    .fill(index < count
                          ? Color(red: 1, green: 0.85, blue: 0.4)
                          : .white.opacity(0.1))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == count - 1 && beadPulse ? 1.5 : 1.0)
                    .animation(.spring(response: 0.2), value: count)
            }
        }
    }

    private var counterDisplay: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())

            Text("\(loc.t(.ofCount)) \(totalBeads)")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var chantButton: some View {
        Button {
            guard count < totalBeads else { return }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                count += 1
                beadPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                beadPulse = false
            }
            if count >= totalBeads {
                withAnimation(.spring) { showCompletion = true }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 1, green: 0.85, blue: 0.4), Color(red: 0.85, green: 0.55, blue: 0.15)],
                            center: .center, startRadius: 0, endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.4), radius: 20)

                VStack(spacing: 2) {
                    Text("ॐ")
                        .font(.system(size: 32))
                    Text(loc.t(.tap))
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                }
                .foregroundStyle(Color(red: 0.08, green: 0.05, blue: 0.15))
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: count)
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                    .symbolEffect(.bounce, value: showCompletion)

                Text(loc.t(.malaComplete))
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                Text("108 × \(mantra.transliteration)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                Text("+108 \(loc.t(.punya))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

                Button {
                    appState.recordMantraChant(count: count)
                    dismiss()
                } label: {
                    Text(loc.t(.namaste))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color(red: 0.08, green: 0.05, blue: 0.15))
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.85, green: 0.65, blue: 0.2)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 25))
                }
            }
        }
    }
}
