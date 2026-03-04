import SwiftUI

struct DeitySelectionView: View {
    let onConfirm: ([DeityID]) -> Void
    @Environment(LocalizationService.self) private var loc
    @State private var selectedIDs: [DeityID] = []
    @State private var appeared = false
    @State private var showMaxWarning = false
    @State private var shakingID: DeityID?
    @State private var showConfirmation = false
    @State private var confirmAnimating = false
    @State private var particlePhase: Bool = false
    @State private var glowRotation: Double = 0
    @State private var pulsePhase: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        ZStack {
            backgroundLayer
            sacredParticles

            VStack(spacing: 0) {
                headerSection
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                ScrollView {
                    primaryHintBanner
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(Deity.allDeities.enumerated()), id: \.element.id) { index, deity in
                            let selectionIndex = selectedIDs.firstIndex(of: deity.id)
                            DeityImageCardView(
                                deity: deity,
                                isSelected: selectionIndex != nil,
                                isPrimary: selectionIndex == 0,
                                selectionOrder: selectionIndex.map { $0 + 1 },
                                isShaking: shakingID == deity.id,
                                appeared: appeared,
                                appearDelay: Double(index) * 0.06,
                                language: loc.currentLanguage
                            ) {
                                handleSelection(deity.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 130)
                }
                .scrollIndicators(.hidden)
            }

            VStack {
                Spacer()
                bottomBar
            }
            .ignoresSafeArea(.container, edges: .bottom)

            if showMaxWarning {
                toastView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            if showConfirmation {
                confirmationOverlay
            }
        }
        .onAppear {

            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                particlePhase = true
            }
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                glowRotation = 360
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulsePhase = true
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.05, green: 0.03, blue: 0.12), location: 0),
                    .init(color: Color(red: 0.08, green: 0.05, blue: 0.18), location: 0.5),
                    .init(color: Color(red: 0.05, green: 0.03, blue: 0.12), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.06), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: -80)
                .blur(radius: 50)
        }
        .ignoresSafeArea()
    }

    private var sacredParticles: some View {
        Canvas { context, size in
            for i in 0..<35 {
                let seed = Double(i) * 137.508
                let x = (sin(seed) * 0.5 + 0.5) * size.width
                let baseY = (cos(seed * 0.7) * 0.5 + 0.5) * size.height
                let y = baseY + (particlePhase ? -20 : 20) * sin(seed * 0.3)
                let radius = 0.4 + sin(seed * 0.5) * 1.0
                let opacity = 0.06 + sin(seed * 0.3) * 0.08
                let goldColor = Color(
                    red: 1.0,
                    green: 0.85 + sin(seed * 0.2) * 0.1,
                    blue: 0.3 + sin(seed * 0.4) * 0.2
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)),
                    with: .color(goldColor.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(red: 1, green: 0.85, blue: 0.4).opacity(0.3),
                                Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.08),
                                Color(red: 1, green: 0.85, blue: 0.4).opacity(0.3),
                            ],
                            center: .center
                        ),
                        lineWidth: 0.8
                    )
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(glowRotation))

                Text("ॐ")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                    .shadow(color: Color(red: 1, green: 0.85, blue: 0.4).opacity(pulsePhase ? 0.6 : 0.2), radius: pulsePhase ? 10 : 5)
            }

            Text(loc.t(.chooseYourGuardians))
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.85, green: 0.65, blue: 0.2)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            Text(loc.t(.selectDeities))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -15)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appeared)
    }

    private var primaryHintBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkle")
                .font(.system(size: 12))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
            Text(primaryHintText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            Image(systemName: "sparkle")
                .font(.system(size: 12))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 1, green: 0.85, blue: 0.4).opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 1, green: 0.85, blue: 0.4).opacity(0.15), lineWidth: 0.5)
                )
        )
    }

    private var primaryHintText: String {
        switch loc.currentLanguage {
        case .english: return "First selection will be your Ishta Devata (Primary Deity)"
        case .chinese: return "第一个选择的将成为您的主尊神（本尊）"
        case .hindi: return "पहला चयन आपका इष्ट देवता (प्रमुख देवता) होगा"
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index < selectedIDs.count
                              ? Color(red: 1, green: 0.85, blue: 0.4)
                              : .white.opacity(0.15))
                        .frame(width: 6, height: 6)
                        .scaleEffect(index < selectedIDs.count ? 1.2 : 1.0)
                        .shadow(color: index < selectedIDs.count ? Color(red: 1, green: 0.85, blue: 0.4).opacity(0.5) : .clear, radius: 3)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: selectedIDs.count)
                }
                Text("\(loc.t(.selected)) \(selectedIDs.count)/3")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .contentTransition(.numericText())
                    .padding(.leading, 3)
            }

            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showConfirmation = true
                }
            } label: {
                Text(loc.t(.confirmSelection))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(selectedIDs.isEmpty ? .white.opacity(0.3) : Color(red: 0.06, green: 0.04, blue: 0.12))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        selectedIDs.isEmpty
                        ? AnyShapeStyle(.white.opacity(0.08))
                        : AnyShapeStyle(LinearGradient(
                            colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.85, green: 0.65, blue: 0.2)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                    )
                    .clipShape(.rect(cornerRadius: 24))
                    .shadow(color: selectedIDs.isEmpty ? .clear : Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.3), radius: 12, y: 4)
            }
            .disabled(selectedIDs.isEmpty)
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
        .padding(.bottom, 30)
        .background(
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.03, blue: 0.12).opacity(0), Color(red: 0.05, green: 0.03, blue: 0.12)],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    private var toastView: some View {
        VStack {
            Text(loc.t(.maxDeitiesAllowed))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.red.opacity(0.85))
                .clipShape(Capsule())
                .padding(.top, 60)
            Spacer()
        }
    }

    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring) { showConfirmation = false }
                }

            Canvas { context, size in
                for i in 0..<30 {
                    let seed = Double(i) * 97.3 + (confirmAnimating ? 80 : 0)
                    let cx = size.width / 2
                    let cy = size.height / 2
                    let angle = seed * 0.1
                    let dist = 40 + sin(seed * 0.3) * 120 + (confirmAnimating ? 20 : -20)
                    let x = cx + cos(angle) * dist
                    let y = cy + sin(angle) * dist
                    let r = 0.8 + sin(seed * 0.5) * 1.2
                    let opacity = 0.1 + sin(seed * 0.2) * 0.12
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)),
                        with: .color(Color(red: 1, green: 0.85, blue: 0.4).opacity(opacity))
                    )
                }
            }
            .allowsHitTesting(false)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(red: 1, green: 0.85, blue: 0.4).opacity(0.5),
                                    .clear,
                                    Color(red: 1, green: 0.85, blue: 0.4).opacity(0.5),
                                ],
                                center: .center
                            ),
                            lineWidth: 1
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(confirmAnimating ? 360 : 0))

                    Text("ॐ")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                        .shadow(color: Color(red: 1, green: 0.85, blue: 0.4).opacity(0.5), radius: 14)
                }

                HStack(spacing: 10) {
                    ForEach(Array(selectedIDs.enumerated()), id: \.element) { index, id in
                        let deity = Deity.deity(for: id)
                        VStack(spacing: 4) {
                            Color(red: 0.1, green: 0.07, blue: 0.18)
                                .frame(width: 52, height: 65)
                                .overlay {
                                    Image(deity.heroImageAsset)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .allowsHitTesting(false)
                                }
                                .clipShape(.rect(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 1, green: 0.85, blue: 0.4).opacity(0.5), lineWidth: 1)
                                )
                                .shadow(color: deity.primaryColor.opacity(0.4), radius: 8)

                            Text(deityDisplayName(deity))
                                .font(.system(size: 11, weight: .semibold, design: .serif))
                                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

                            if index == 0 {
                                Text(loc.t(.ishtaDevata))
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4).opacity(0.7))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(red: 1, green: 0.85, blue: 0.4).opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                Text(selectedBlessingText)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 16)

                Button {
                    let ids = selectedIDs
                    onConfirm(ids)
                } label: {
                    Text(loc.t(.beginYourJourney))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(red: 0.06, green: 0.04, blue: 0.12))
                        .frame(width: 200, height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.85, green: 0.65, blue: 0.2)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 22))
                        .shadow(color: Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.4), radius: 12, y: 4)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.06, green: 0.04, blue: 0.14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 1, green: 0.85, blue: 0.4).opacity(0.3), Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.08)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )
                    .shadow(color: Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.1), radius: 30)
            )
            .padding(.horizontal, 28)
            .scaleEffect(showConfirmation ? 1 : 0.85)
            .opacity(showConfirmation ? 1 : 0)
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                confirmAnimating = true
            }
        }
    }

    private func deityDisplayName(_ deity: Deity) -> String {
        switch loc.currentLanguage {
        case .english: return deity.nameEnglish
        case .chinese: return deity.nameChinese
        case .hindi: return deity.nameHindi
        }
    }

    private var selectedBlessingText: String {
        guard let firstID = selectedIDs.first,
              let first = Deity.allDeities.first(where: { $0.id == firstID }) else { return "" }
        return first.localizedBlessing(for: loc.currentLanguage)
    }

    private func handleSelection(_ id: DeityID) {
        if let idx = selectedIDs.firstIndex(of: id) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedIDs.remove(at: idx)
            }
        } else if selectedIDs.count >= 3 {
            shakingID = id
            withAnimation(.spring) { showMaxWarning = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakingID = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.spring) { showMaxWarning = false }
            }
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                selectedIDs.append(id)
            }
        }
    }
}

struct DeityImageCardView: View {
    let deity: Deity
    let isSelected: Bool
    let isPrimary: Bool
    let selectionOrder: Int?
    let isShaking: Bool
    let appeared: Bool
    let appearDelay: Double
    let language: AppLanguage
    let onTap: () -> Void

    @State private var glowRotation: Double = 0
    @State private var selectionPulse: Bool = false

    private let goldColor = Color(red: 1, green: 0.85, blue: 0.4)
    private let cardBg = Color(red: 0.08, green: 0.06, blue: 0.15)

    var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .onChange(of: isSelected) { _, newValue in
            handleSelectionChange(newValue)
        }
    }

    private var cardContent: some View {
        VStack(spacing: 0) {
            deityImageArea
            deityInfoArea
        }
        .background(cardBg)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isSelected
                    ? LinearGradient(colors: [goldColor.opacity(0.8), deity.primaryColor.opacity(0.4), goldColor.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [.white.opacity(0.08), .white.opacity(0.03)], startPoint: .top, endPoint: .bottom),
                    lineWidth: isSelected ? 1.5 : 0.5
                )
        )
        .overlay {
            if isSelected {
                selectedGlowBorder
            }
        }
        .overlay(alignment: .topLeading) {
            if isPrimary {
                HStack(spacing: 3) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 8))
                    Text(primaryLabel)
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundStyle(Color(red: 0.06, green: 0.04, blue: 0.12))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(goldColor)
                .clipShape(Capsule())
                .padding(6)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .overlay(alignment: .topTrailing) {
            if isSelected {
                ZStack {
                    Circle()
                        .fill(cardBg)
                        .frame(width: 22, height: 22)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(goldColor)
                        .shadow(color: goldColor.opacity(0.5), radius: 4)
                }
                .padding(6)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .shadow(color: isSelected ? deity.primaryColor.opacity(0.25) : .black.opacity(0.2), radius: isSelected ? 12 : 4, y: 2)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)
        .modifier(ShakeModifier(shakeCount: isShaking ? 6 : 0))
        .animation(.linear(duration: 0.5), value: isShaking)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 50)
        .scaleEffect(appeared ? 1 : 0.8)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.7).delay(appearDelay),
            value: appeared
        )
    }

    private var primaryLabel: String {
        switch language {
        case .english: return "PRIMARY"
        case .chinese: return "主尊"
        case .hindi: return "प्रमुख"
        }
    }

    @ViewBuilder
    private var selectedGlowBorder: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(
                AngularGradient(
                    colors: [
                        goldColor.opacity(0.4),
                        deity.primaryColor.opacity(0.15),
                        goldColor.opacity(0.4),
                        deity.primaryColor.opacity(0.15),
                    ],
                    center: .center
                ),
                lineWidth: 1.5
            )
            .rotationEffect(.degrees(glowRotation))
            .blur(radius: 2)
            .opacity(selectionPulse ? 0.7 : 0.3)
            .allowsHitTesting(false)
    }

    private var deityImageArea: some View {
        Color(red: 0.08, green: 0.06, blue: 0.15)
            .aspectRatio(0.75, contentMode: .fit)
            .overlay {
                Image(deity.heroImageAsset)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: cardBg.opacity(0.8), location: 0.85),
                        .init(color: cardBg, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 50)
                .allowsHitTesting(false)
            }
            .overlay {
                if isSelected {
                    Color(deity.primaryColor).opacity(0.08)
                        .allowsHitTesting(false)
                }
            }
    }

    private var deityInfoArea: some View {
        VStack(spacing: 3) {
            Text(primaryName)
                .font(.system(size: 14, weight: .bold, design: .serif))
                .foregroundStyle(isSelected ? goldColor : .white.opacity(0.9))

            Text(secondaryName)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))

            HStack(spacing: 3) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 8))
                Text(formatCount(deity.followerCount))
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundStyle(.white.opacity(0.3))
            .padding(.top, 2)
        }
        .padding(.vertical, 10)
    }

    private func handleSelectionChange(_ newValue: Bool) {
        if newValue {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                glowRotation = 360
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                selectionPulse = true
            }
        } else {
            glowRotation = 0
            selectionPulse = false
        }
    }

    private var primaryName: String {
        switch language {
        case .english: return deity.nameEnglish
        case .chinese: return deity.nameChinese
        case .hindi: return deity.nameHindi
        }
    }

    private var secondaryName: String {
        switch language {
        case .english: return deity.nameHindi
        case .chinese: return deity.nameHindi
        case .hindi: return deity.nameChinese
        }
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}

struct ShakeModifier: ViewModifier, Animatable {
    var shakeCount: Double

    var animatableData: Double {
        get { shakeCount }
        set { shakeCount = newValue }
    }

    func body(content: Content) -> some View {
        content.offset(x: sin(shakeCount * .pi * 2) * 6)
    }
}
