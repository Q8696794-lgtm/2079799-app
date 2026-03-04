import SwiftUI

struct DarshanView: View {
    @Environment(AppState.self) private var appState
    @Environment(LocalizationService.self) private var loc
    @State private var selectedDeityIndex: Int = 0
    @State private var showAarti = false
    @State private var flamePhase = false
    @State private var darshanCompleted = false
    @State private var particlePhase = false

    private var currentDeity: Deity? {
        let deities = appState.selectedDeities
        guard !deities.isEmpty, selectedDeityIndex < deities.count else { return deities.first }
        return deities[selectedDeityIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        deityHeader
                            .padding(.bottom, 24)

                        if appState.selectedDeities.count > 1 {
                            deityPicker
                                .padding(.bottom, 24)
                        }

                        statsRow
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)

                        darshanButton
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)

                        aartiButton
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                        if appState.selectedDeities.count > 1 {
                            followerSection
                                .padding(.horizontal, 16)
                                .padding(.bottom, 24)
                        }

                        offeringSection
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)

                        dailyBlessingCard
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(loc.t(.devaBhakti))
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
                }
            }
            .sheet(isPresented: $showAarti) {
                AartiView(deity: currentDeity ?? Deity.allDeities[0])
            }
        }
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.06, green: 0.04, blue: 0.12), location: 0),
                    .init(color: (currentDeity?.primaryColor ?? .blue).opacity(0.15), location: 0.5),
                    .init(color: Color(red: 0.06, green: 0.04, blue: 0.12), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Canvas { context, size in
                for i in 0..<20 {
                    let seed = Double(i) * 137.508
                    let x = (sin(seed) * 0.5 + 0.5) * size.width
                    let baseY = (cos(seed * 0.7) * 0.5 + 0.5) * size.height
                    let y = baseY + (particlePhase ? -15 : 15)
                    let r = 1.0 + sin(seed * 0.5) * 1.0
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)),
                        with: .color(.yellow.opacity(0.1))
                    )
                }
            }
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    particlePhase = true
                }
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

    private var deityHeader: some View {
        VStack(spacing: 16) {
            if let deity = currentDeity {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [deity.primaryColor.opacity(0.3), deity.primaryColor.opacity(0.05)],
                                center: .center, startRadius: 0, endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)

                    if darshanCompleted {
                        Circle()
                            .stroke(Color(red: 1, green: 0.85, blue: 0.4).opacity(0.5), lineWidth: 2)
                            .frame(width: 200, height: 200)
                            .scaleEffect(darshanCompleted ? 1.15 : 1.0)
                            .opacity(darshanCompleted ? 0 : 1)
                            .animation(.easeOut(duration: 1), value: darshanCompleted)
                    }

                    Color.clear
                        .frame(width: 160, height: 200)
                        .overlay {
                            CachedAsyncImage(url: deity.heroImageURL)
                                .allowsHitTesting(false)
                        }
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(red: 1, green: 0.85, blue: 0.4).opacity(0.4), deity.primaryColor.opacity(0.2)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: deity.primaryColor.opacity(0.4), radius: 20)
                }

                Text(deityName(deity))
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.85, green: 0.65, blue: 0.2)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )

                Text(deity.localizedDescription(for: loc.currentLanguage))
                    .font(.system(size: 13, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                    Text("\(formatFollowerCount(deity.followerCount)) \(loc.t(.followers))")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.top, 16)
    }

    private var deityPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(Array(appState.selectedDeities.enumerated()), id: \.element.id) { index, deity in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDeityIndex = index
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Color.clear
                                .frame(width: 36, height: 44)
                                .overlay {
                                    CachedAsyncImage(url: deity.heroImageURL)
                                        .allowsHitTesting(false)
                                }
                                .clipShape(.rect(cornerRadius: 8))

                            Text(deityName(deity))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(selectedDeityIndex == index ? Color(red: 1, green: 0.85, blue: 0.4) : .white.opacity(0.5))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedDeityIndex == index ? deity.primaryColor.opacity(0.25) : .white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedDeityIndex == index ? Color(red: 1, green: 0.85, blue: 0.4).opacity(0.5) : .clear, lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(title: loc.t(.streak), value: "\(appState.progress.dailyDarshanStreak)", icon: "flame.fill", color: .orange)
            statCard(title: loc.t(.punya), value: "\(appState.progress.punyaPoints)", icon: "sparkles", color: .yellow)
            statCard(title: loc.t(.darshan), value: "\(appState.progress.totalDarshanCount)", icon: "eye.fill", color: .blue)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.08), lineWidth: 0.5)
                )
        )
    }

    private var darshanButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                darshanCompleted = true
            }
            appState.recordDarshan()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                darshanCompleted = false
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 20))
                    .symbolEffect(.pulse, isActive: !darshanCompleted)
                VStack(alignment: .leading, spacing: 2) {
                    Text(loc.t(.dailyDarshan))
                        .font(.system(size: 16, weight: .bold))
                    Text(darshanCompleted ? loc.t(.darshanComplete) : loc.t(.receiveBlessings))
                        .font(.system(size: 12, weight: .medium))
                        .opacity(0.8)
                }
                Spacer()
                Text("+10")
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .foregroundStyle(darshanCompleted ? Color(red: 0.08, green: 0.05, blue: 0.15) : .white)
            .padding(.horizontal, 20)
            .frame(height: 64)
            .background(
                darshanCompleted
                ? AnyShapeStyle(LinearGradient(
                    colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.85, green: 0.65, blue: 0.2)],
                    startPoint: .leading, endPoint: .trailing
                ))
                : AnyShapeStyle(LinearGradient(
                    colors: [(currentDeity?.primaryColor ?? .blue).opacity(0.4), (currentDeity?.primaryColor ?? .blue).opacity(0.2)],
                    startPoint: .leading, endPoint: .trailing
                ))
            )
            .clipShape(.rect(cornerRadius: 20))
        }
        .sensoryFeedback(.success, trigger: darshanCompleted)
    }

    private var aartiButton: some View {
        Button {
            showAarti = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(loc.t(.virtualAarti))
                        .font(.system(size: 16, weight: .bold))
                    Text(loc.t(.lightSacredFlame))
                        .font(.system(size: 12, weight: .medium))
                        .opacity(0.6)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.4)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.orange.opacity(0.2), lineWidth: 0.5)
                    )
            )
        }
    }

    private var offeringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.t(.sacredOffering))
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

            if let deity = currentDeity {
                HStack(spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.green)
                        .frame(width: 48, height: 48)
                        .background(.green.opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(deity.localizedOffering(for: loc.currentLanguage))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("\(loc.t(.offeringFor)) \(deityName(deity))")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.05))
                )
            }
        }
    }

    private var followerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.t(.followers))
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                .textCase(.uppercase)

            VStack(spacing: 8) {
                ForEach(appState.selectedDeities) { deity in
                    HStack(spacing: 12) {
                        Color.clear
                            .frame(width: 36, height: 44)
                            .overlay {
                                CachedAsyncImage(url: deity.heroImageURL)
                                    .allowsHitTesting(false)
                            }
                            .clipShape(.rect(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(deityName(deity))
                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                .foregroundStyle(.white)
                            if deity.id == appState.primaryDeityID {
                                Text(loc.t(.ishtaDevata))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4).opacity(0.8))
                            }
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10))
                            Text(formatFollowerCount(deity.followerCount))
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        deity.id == appState.primaryDeityID
                                        ? Color(red: 1, green: 0.85, blue: 0.4).opacity(0.2)
                                        : .white.opacity(0.05),
                                        lineWidth: 0.5
                                    )
                            )
                    )
                }
            }
        }
    }

    private func formatFollowerCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }

    private var dailyBlessingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.quote")
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                Text(loc.t(.dailyBlessing))
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
            }

            if let deity = currentDeity {
                Text(deity.localizedBlessing(for: loc.currentLanguage))
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineSpacing(4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}

struct AartiView: View {
    let deity: Deity
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationService.self) private var loc
    @State private var flameScale: CGFloat = 1.0
    @State private var flameOffset: CGFloat = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.04, blue: 0.10)
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    Color.clear
                        .frame(width: 120, height: 150)
                        .overlay {
                            CachedAsyncImage(url: deity.heroImageURL)
                                .allowsHitTesting(false)
                        }
                        .clipShape(.rect(cornerRadius: 12))
                        .shadow(color: deity.primaryColor.opacity(0.5), radius: 20)

                    Text("ॐ")
                        .font(.system(size: 48))
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

                    VStack(spacing: 8) {
                        HStack(spacing: 20) {
                            flameView
                            flameView
                            flameView
                            flameView
                            flameView
                        }
                    }

                    Text("\(loc.t(.aartiFor)) \(deityDisplayName)")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

                    Text(loc.t(.aartiInstruction))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(loc.t(.done)) { dismiss() }
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                flameScale = 1.3
                flameOffset = -3
            }
        }
    }

    private var deityDisplayName: String {
        switch loc.currentLanguage {
        case .english: return deity.nameEnglish
        case .chinese: return deity.nameChinese
        case .hindi: return deity.nameHindi
        }
    }

    private var flameView: some View {
        Text("🪔")
            .font(.system(size: 36))
            .scaleEffect(flameScale)
            .offset(y: flameOffset)
    }
}
