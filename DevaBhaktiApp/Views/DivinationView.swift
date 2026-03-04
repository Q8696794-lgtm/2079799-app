import SwiftUI

struct DivinationView: View {
    @Environment(AppState.self) private var appState
    @Environment(LocalizationService.self) private var loc
    @State private var viewModel = DivinationViewModel()

    private let goldLight = Color(red: 1, green: 0.85, blue: 0.4)
    private let goldDark = Color(red: 0.85, green: 0.65, blue: 0.2)
    private let bgDark = Color(red: 0.06, green: 0.04, blue: 0.12)

    private var currentDeity: Deity {
        let deities = appState.selectedDeities
        guard !deities.isEmpty, viewModel.selectedDeityIndex < deities.count else {
            return appState.selectedDeities.first ?? Deity.allDeities[0]
        }
        return deities[viewModel.selectedDeityIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                switch viewModel.phase {
                case .input:
                    inputPhaseView
                        .transition(.opacity)
                case .shuffling:
                    shufflingPhaseView
                        .transition(.opacity)
                case .revealing:
                    revealingPhaseView
                        .transition(.opacity)
                case .result:
                    resultPhaseView
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: viewModel.phase)
            .navigationTitle(loc.t(.divination))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            viewModel.showCardGallery = true
                        } label: {
                            Image(systemName: "rectangle.grid.3x2.fill")
                                .foregroundStyle(goldLight)
                        }

                        if !viewModel.records.isEmpty {
                            Button {
                                viewModel.showHistory = true
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundStyle(goldLight)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showHistory) {
                DivinationHistoryView(records: viewModel.records)
            }
            .sheet(isPresented: $viewModel.showCardGallery) {
                CardGalleryView(deityID: currentDeity.id, deityColor: currentDeity.primaryColor)
            }
            .sheet(item: $viewModel.selectedDrawnCard) { drawn in
                CardDetailSheet(drawn: drawn, language: loc.currentLanguage, deityColor: currentDeity.primaryColor)
            }
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: bgDark, location: 0),
                    .init(color: currentDeity.primaryColor.opacity(0.12), location: 0.5),
                    .init(color: bgDark, location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )

            particleField
        }
    }

    @State private var particlePhase = false
    private var particleField: some View {
        Canvas { context, size in
            for i in 0..<30 {
                let seed = Double(i) * 137.508
                let x = (sin(seed) * 0.5 + 0.5) * size.width
                let baseY = (cos(seed * 0.7) * 0.5 + 0.5) * size.height
                let y = baseY + (particlePhase ? -12 : 12)
                let r = 1.0 + sin(seed * 0.3) * 0.8
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)),
                    with: .color(goldLight.opacity(0.08))
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

    // MARK: - Input Phase

    private var inputPhaseView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if appState.selectedDeities.count > 1 {
                    deitySelector
                }

                deityHeaderSmall

                if viewModel.hasReadForDeity(currentDeity.id) {
                    alreadyReadView
                } else {
                    questionInputSection
                    quickTagsSection
                    suitInfoBar
                    startButton
                }
            }
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private var deitySelector: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(Array(appState.selectedDeities.enumerated()), id: \.element.id) { index, deity in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedDeityIndex = index
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Color.clear
                                .frame(width: 24, height: 30)
                                .overlay {
                                    Image(deity.heroImageAsset)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .allowsHitTesting(false)
                                }
                                .clipShape(.rect(cornerRadius: 4))

                            Text(deity.localizedName(for: loc.currentLanguage))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(viewModel.selectedDeityIndex == index ? goldLight : .white.opacity(0.5))

                            if viewModel.hasReadForDeity(deity.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.green.opacity(0.8))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedDeityIndex == index ? deity.primaryColor.opacity(0.25) : .white.opacity(0.05))
                                .overlay(
                                    Capsule()
                                        .stroke(viewModel.selectedDeityIndex == index ? goldLight.opacity(0.4) : .clear, lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private var deityHeaderSmall: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [currentDeity.primaryColor.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 70))
                    .frame(width: 140, height: 140)

                Color.clear
                    .frame(width: 100, height: 130)
                    .overlay {
                        Image(currentDeity.heroImageAsset)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(goldDark.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: currentDeity.primaryColor.opacity(0.4), radius: 16)
            }

            VStack(spacing: 4) {
                Text(askDeityText)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(goldLight)
                Text("Trikal Darshan · \(trikalaText)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.top, 8)
    }

    private var askDeityText: String {
        let name = currentDeity.localizedName(for: loc.currentLanguage)
        switch loc.currentLanguage {
        case .english: return "Ask \(name)"
        case .chinese: return "向\(name)提问"
        case .hindi: return "\(name) से पूछें"
        }
    }

    private var trikalaText: String {
        switch loc.currentLanguage {
        case .english: return "Three Time Contemplation"
        case .chinese: return "三时观照"
        case .hindi: return "त्रिकाल दर्शन"
        }
    }

    private var questionInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(questionPlaceholder, text: $viewModel.question, axis: .vertical)
                .lineLimit(3...5)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(goldDark.opacity(0.2), lineWidth: 0.5)
                        )
                )
        }
        .padding(.horizontal, 16)
    }

    private var questionPlaceholder: String {
        switch loc.currentLanguage {
        case .english: return "What guidance do you seek today?"
        case .chinese: return "今日你想寻求什么指引？"
        case .hindi: return "आज आप क्या मार्गदर्शन चाहते हैं?"
        }
    }

    private var quickTagsSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(quickTags, id: \.self) { tag in
                    Button {
                        viewModel.question = tag
                    } label: {
                        Text(tag)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(goldLight.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(goldDark.opacity(0.1))
                                    .overlay(Capsule().stroke(goldDark.opacity(0.2), lineWidth: 0.5))
                            )
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private var quickTags: [String] {
        switch loc.currentLanguage {
        case .english: return ["Career", "Love", "Health", "Wealth", "Study", "Family"]
        case .chinese: return ["事业", "爱情", "健康", "财运", "学业", "家庭"]
        case .hindi: return ["करियर", "प्रेम", "स्वास्थ्य", "धन", "शिक्षा", "परिवार"]
        }
    }

    private var suitInfoBar: some View {
        HStack(spacing: 0) {
            ForEach(CardSuit.allCases, id: \.self) { suit in
                VStack(spacing: 4) {
                    Image(systemName: suit.sfSymbol)
                        .font(.system(size: 14))
                        .foregroundStyle(suitColor(suit))
                    Text(suit.localizedName(for: loc.currentLanguage))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.04))
        )
        .padding(.horizontal, 16)
    }

    private var startButton: some View {
        Button {
            viewModel.performDivination(deityID: currentDeity.id, language: loc.currentLanguage)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text(startDivinationText)
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(bgDark)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(colors: [goldLight, goldDark], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(.rect(cornerRadius: 27))
            .shadow(color: goldDark.opacity(0.3), radius: 12, y: 6)
        }
        .padding(.horizontal, 24)
        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.phase)
    }

    private var startDivinationText: String {
        switch loc.currentLanguage {
        case .english: return "Begin Divination"
        case .chinese: return "开始占卜"
        case .hindi: return "भविष्यवाणी शुरू करें"
        }
    }

    private var alreadyReadView: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 48))
                .foregroundStyle(goldLight.opacity(0.5))
                .symbolEffect(.pulse)

            Text(alreadyReadText)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Text(viewModel.timeUntilReset)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(goldLight)
                .contentTransition(.numericText())

            if appState.selectedDeities.count > 1 {
                let availableDeities = appState.selectedDeities.filter { !viewModel.hasReadForDeity($0.id) }
                if !availableDeities.isEmpty {
                    VStack(spacing: 8) {
                        Text(otherDeitiesAvailableText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))

                        HStack(spacing: 8) {
                            ForEach(availableDeities) { deity in
                                Button {
                                    if let idx = appState.selectedDeities.firstIndex(where: { $0.id == deity.id }) {
                                        withAnimation(.spring(response: 0.3)) {
                                            viewModel.selectedDeityIndex = idx
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(deity.symbol)
                                            .font(.system(size: 14))
                                        Text(deity.localizedName(for: loc.currentLanguage))
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(goldLight)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(deity.primaryColor.opacity(0.2))
                                            .overlay(Capsule().stroke(goldLight.opacity(0.3), lineWidth: 0.5))
                                    )
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.04))
        )
        .padding(.horizontal, 16)
    }

    private var alreadyReadText: String {
        let name = currentDeity.localizedName(for: loc.currentLanguage)
        switch loc.currentLanguage {
        case .english: return "Today's oracle from \(name) has been granted.\nReturn after reset for a new reading."
        case .chinese: return "今日\(name)的神谕已赐\n重置后可再次求签"
        case .hindi: return "\(name) का आज का दैवीय संदेश दिया जा चुका है।\nरीसेट के बाद नई भविष्यवाणी के लिए आएं।"
        }
    }

    private var otherDeitiesAvailableText: String {
        switch loc.currentLanguage {
        case .english: return "You can still consult:"
        case .chinese: return "你还可以向以下主神占卜："
        case .hindi: return "आप अभी भी परामर्श कर सकते हैं:"
        }
    }

    // MARK: - Shuffling Phase

    @State private var shuffleAngle: Double = 0

    private var shufflingPhaseView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("ॐ")
                .font(.system(size: 48))
                .foregroundStyle(goldLight)
                .rotationEffect(.degrees(shuffleAngle))
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        shuffleAngle = 360
                    }
                }

            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    cardBackView
                        .frame(width: 90, height: 126)
                        .rotationEffect(.degrees(Double(i) * 6 - 21 + sin(viewModel.shuffleProgress * .pi * 4 + Double(i)) * 15))
                        .offset(x: sin(viewModel.shuffleProgress * .pi * 2 + Double(i) * 0.8) * 30)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.shuffleProgress)
                }
            }
            .frame(height: 160)

            VStack(spacing: 8) {
                Text(shufflingText)
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.7))

                ProgressView(value: viewModel.shuffleProgress)
                    .tint(goldDark)
                    .frame(width: 200)
            }

            Spacer()
        }
    }

    private var shufflingText: String {
        switch loc.currentLanguage {
        case .english: return "Shuffling the sacred cards..."
        case .chinese: return "神圣卡牌洗牌中..."
        case .hindi: return "पवित्र कार्ड फेंटे जा रहे हैं..."
        }
    }

    // MARK: - Revealing Phase

    private var revealingPhaseView: some View {
        VStack(spacing: 24) {
            Spacer()

            HStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { index in
                    if index <= viewModel.revealedCardIndex, index < viewModel.drawnCards.count {
                        let drawn = viewModel.drawnCards[index]
                        miniCardFace(drawn: drawn)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.3).combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else {
                        cardBackView
                            .frame(width: 100, height: 150)
                            .opacity(0.5)
                    }
                }
            }

            HStack(spacing: 24) {
                ForEach(CardPosition.allCases, id: \.self) { pos in
                    Text(pos.localizedName(for: loc.currentLanguage))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(pos.rawValue <= viewModel.revealedCardIndex ? goldLight : .white.opacity(0.3))
                }
            }

            Spacer()
        }
    }

    // MARK: - Result Phase

    private var resultPhaseView: some View {
        ScrollView {
            VStack(spacing: 24) {
                resultCardsRow

                Text(tapCardHint)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.35))

                interpretationSection

                if viewModel.phase == .result {
                    actionButtons
                }
            }
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private var tapCardHint: String {
        switch loc.currentLanguage {
        case .english: return "Tap a card for detailed revelation"
        case .chinese: return "点击卡牌查看详细启示"
        case .hindi: return "विस्तृत रहस्योद्घाटन के लिए कार्ड टैप करें"
        }
    }

    private var resultCardsRow: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                ForEach(Array(viewModel.drawnCards.enumerated()), id: \.offset) { _, drawn in
                    resultCardView(drawn: drawn)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.top, 8)
    }

    private func resultCardView(drawn: DrawnCard) -> some View {
        Button {
            viewModel.selectedDrawnCard = drawn
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [currentDeity.primaryColor.opacity(0.4), currentDeity.primaryColor.opacity(0.1)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    LinearGradient(colors: [goldLight.opacity(0.5), goldDark.opacity(0.3)], startPoint: .top, endPoint: .bottom),
                                    lineWidth: 1.5
                                )
                        )

                    VStack(spacing: 4) {
                        Text(drawn.card.romanNumeral)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(goldLight.opacity(0.6))

                        if let uiImage = UIImage(named: drawn.card.imageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 85)
                                .clipShape(.rect(cornerRadius: 8))
                        }

                        Text(drawn.card.localizedName(for: loc.currentLanguage))
                            .font(.system(size: 9, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        Image(systemName: drawn.card.suit.sfSymbol)
                            .font(.system(size: 10))
                            .foregroundStyle(suitColor(drawn.card.suit))
                    }
                    .padding(6)
                }
                .frame(height: 160)

                Text(drawn.position.localizedName(for: loc.currentLanguage))
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(goldLight)
                    .multilineTextAlignment(.center)

                Text(drawn.card.localizedMeaning(for: loc.currentLanguage))
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var interpretationSection: some View {
        VStack(spacing: 16) {
            cardInterpretationBlock
            aiInterpretationBlock
        }
    }

    private var cardInterpretationBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "text.book.closed.fill")
                    .foregroundStyle(goldLight)
                Text(interpretationTitle)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(goldLight)
            }

            Text(viewModel.interpretationText)
                .font(.system(size: 14, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(6)

            if viewModel.isTypewriting {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(goldLight)
                            .frame(width: 4, height: 4)
                            .opacity(0.6)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(goldDark.opacity(0.15), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
    }

    private var aiInterpretationBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(goldLight)
                    .symbolEffect(.pulse, isActive: viewModel.isLoadingAI)
                Text(aiOracleTitle)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(goldLight)
                Spacer()
                if viewModel.isLoadingAI {
                    ProgressView()
                        .tint(goldLight)
                        .scaleEffect(0.7)
                }
            }

            if viewModel.isLoadingAI && viewModel.aiInterpretation.isEmpty {
                VStack(spacing: 12) {
                    Text(aiLoadingText)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            if !viewModel.aiInterpretation.isEmpty {
                Text(viewModel.aiInterpretation)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(6)
                    .textSelection(.enabled)
            }

            if let error = viewModel.aiError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.yellow.opacity(0.7))
                    Text(error)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [currentDeity.primaryColor.opacity(0.08), .white.opacity(0.04)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(colors: [goldLight.opacity(0.2), goldDark.opacity(0.1)], startPoint: .top, endPoint: .bottom),
                            lineWidth: 0.5
                        )
                )
        )
        .padding(.horizontal, 16)
    }

    private var aiOracleTitle: String {
        let name = currentDeity.localizedName(for: loc.currentLanguage)
        switch loc.currentLanguage {
        case .english: return "\(name)'s Oracle"
        case .chinese: return "\(name)的神谕"
        case .hindi: return "\(name) का दैवीय संदेश"
        }
    }

    private var aiLoadingText: String {
        let name = currentDeity.localizedName(for: loc.currentLanguage)
        switch loc.currentLanguage {
        case .english: return "\(name) is contemplating your destiny..."
        case .chinese: return "\(name)正在冥想你的命运..."
        case .hindi: return "\(name) आपकी नियति पर ध्यान कर रहे हैं..."
        }
    }

    private var interpretationTitle: String {
        switch loc.currentLanguage {
        case .english: return "Divine Interpretation"
        case .chinese: return "神圣解读"
        case .hindi: return "दिव्य व्याख्या"
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.reset()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                    Text(newReadingText)
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(goldLight)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .stroke(goldLight.opacity(0.3), lineWidth: 1)
                )
            }

            Button {
                viewModel.showHistory = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text(historyText)
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.05))
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private var newReadingText: String {
        switch loc.currentLanguage {
        case .english: return "New Reading"
        case .chinese: return "重新占卜"
        case .hindi: return "नई भविष्यवाणी"
        }
    }

    private var historyText: String {
        switch loc.currentLanguage {
        case .english: return "History"
        case .chinese: return "历史记录"
        case .hindi: return "इतिहास"
        }
    }

    // MARK: - Card Components

    private var cardBackView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.1, blue: 0.35), Color(red: 0.1, green: 0.05, blue: 0.2)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(goldDark.opacity(0.4), lineWidth: 1.5)
            )
            .overlay {
                VStack(spacing: 4) {
                    Text("ॐ")
                        .font(.system(size: 24))
                        .foregroundStyle(goldLight.opacity(0.4))
                    Circle()
                        .stroke(goldDark.opacity(0.2), lineWidth: 0.5)
                        .frame(width: 30, height: 30)
                }
            }
    }

    private func miniCardFace(drawn: DrawnCard) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [currentDeity.primaryColor.opacity(0.5), currentDeity.primaryColor.opacity(0.15)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(goldDark.opacity(0.6), lineWidth: 1.5)
                )

            VStack(spacing: 4) {
                Text(drawn.card.romanNumeral)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(goldLight.opacity(0.7))

                if let uiImage = UIImage(named: drawn.card.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 55, height: 70)
                        .clipShape(.rect(cornerRadius: 6))
                } else {
                    Color.clear
                        .frame(width: 55, height: 70)
                        .overlay {
                            Image(currentDeity.heroImageAsset)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        }
                        .clipShape(.rect(cornerRadius: 6))
                }

                Text(drawn.card.localizedName(for: loc.currentLanguage))
                    .font(.system(size: 9, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(6)
        }
        .frame(width: 100, height: 150)
    }

    private func suitColor(_ suit: CardSuit) -> Color {
        switch suit {
        case .dharma: return .orange
        case .karma: return .red
        case .kama: return .pink
        case .moksha: return .cyan
        }
    }
}
