import SwiftUI

@Observable
@MainActor
class DivinationViewModel {
    var selectedDeityIndex: Int = 0
    var question: String = ""
    var phase: DivinationPhase = .input
    var drawnCards: [DrawnCard] = []
    var interpretationText: String = ""
    var isTypewriting: Bool = false
    var aiInterpretation: String = ""
    var isLoadingAI: Bool = false
    var aiError: String? = nil
    var shuffleProgress: Double = 0
    var revealedCardIndex: Int = -1
    var showHistory: Bool = false
    var showCardGallery: Bool = false
    var selectedDrawnCard: DrawnCard? = nil
    var records: [DivinationRecord] = []
    var deityReadStatus: [String: Date] = [:]
    var nextResetDate: Date = Date()

    private let recordsKey = "divinationRecords"
    private let deityReadKey = "deityDivinationDates"
    private var timerTask: Task<Void, Never>?

    init() {
        loadRecords()
        loadDeityReadStatus()
        computeNextReset()
        startTimer()
    }

    func cancelTimer() {
        timerTask?.cancel()
    }

    func hasReadForDeity(_ deityID: DeityID) -> Bool {
        guard let lastRead = deityReadStatus[deityID.rawValue] else { return false }
        return lastRead >= lastResetTime()
    }

    private func lastResetTime() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        let now = Date()
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.hour = 5
        comps.minute = 0
        comps.second = 0
        guard let today5AM = cal.date(from: comps) else { return now }
        return now >= today5AM ? today5AM : cal.date(byAdding: .day, value: -1, to: today5AM) ?? now
    }

    private func computeNextReset() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        let now = Date()
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.hour = 5
        comps.minute = 0
        comps.second = 0
        guard let today5AM = cal.date(from: comps) else { return }
        nextResetDate = now >= today5AM ? cal.date(byAdding: .day, value: 1, to: today5AM) ?? now : today5AM
    }

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Date() >= nextResetDate {
                    computeNextReset()
                }
            }
        }
    }

    func performDivination(deityID: DeityID, language: AppLanguage) {
        guard !hasReadForDeity(deityID) else { return }

        phase = .shuffling
        shuffleProgress = 0

        let allCards = DivinationCard.allCards(for: deityID)
        let selected = Array(allCards.shuffled().prefix(3))
        let positions: [CardPosition] = [.sthiti, .pravritti, .phala]

        drawnCards = zip(selected, positions).map { DrawnCard(card: $0.0, position: $0.1) }

        Task {
            for i in 0..<20 {
                try? await Task.sleep(for: .milliseconds(100))
                shuffleProgress = Double(i + 1) / 20.0
            }

            phase = .revealing
            revealedCardIndex = -1

            for i in 0..<3 {
                try? await Task.sleep(for: .milliseconds(600))
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    revealedCardIndex = i
                }
            }

            try? await Task.sleep(for: .milliseconds(400))

            withAnimation(.easeInOut(duration: 0.3)) {
                phase = .result
            }

            generateInterpretation(deityID: deityID, language: language)
            await fetchAIInterpretation(deityID: deityID, language: language)

            let fullInterpretation = aiInterpretation.isEmpty ? buildFullInterpretation(deityID: deityID, language: language) : aiInterpretation

            let record = DivinationRecord(
                id: UUID().uuidString,
                date: Date(),
                deityID: deityID,
                question: question,
                cards: drawnCards,
                interpretation: fullInterpretation
            )
            records.insert(record, at: 0)
            saveRecords()

            deityReadStatus[deityID.rawValue] = Date()
            saveDeityReadStatus()
        }
    }

    func reset() {
        withAnimation(.spring(response: 0.4)) {
            phase = .input
            question = ""
            drawnCards = []
            interpretationText = ""
            aiInterpretation = ""
            isLoadingAI = false
            aiError = nil
            revealedCardIndex = -1
            shuffleProgress = 0
            isTypewriting = false
        }
        computeNextReset()
    }

    func crossSuitInsight(language: AppLanguage) -> String? {
        guard drawnCards.count == 3 else { return nil }
        let suits = Set(drawnCards.map(\.card.suit))

        if suits.count == 1 {
            let suitName = suits.first!.localizedName(for: language)
            switch language {
            case .english: return "Triple \(suitName) — An exceptionally strong signal in this dimension. Pay special attention to this area of life."
            case .chinese: return "三张同组「\(suitName)」— 极为强烈的单一维度信号，需要特别关注该领域。"
            case .hindi: return "तीनों \(suitName) — इस आयाम में अत्यंत शक्तिशाली संकेत। जीवन के इस क्षेत्र पर विशेष ध्यान दें।"
            }
        }

        guard suits.count >= 2 else { return nil }
        let pair = suits

        if pair.contains(.dharma) && pair.contains(.karma) {
            switch language {
            case .english: return "Dharma + Karma: Your current efforts are being examined against the path of righteousness."
            case .chinese: return "法性 + 业果：当前的努力是否符合正道，责任与行动的关联正在显现。"
            case .hindi: return "धर्म + कर्म: आपके वर्तमान प्रयासों को धर्म के मार्ग पर परखा जा रहा है।"
            }
        }
        if pair.contains(.dharma) && pair.contains(.kama) {
            switch language {
            case .english: return "Dharma + Kama: Tension between duty and desire — examine if your heart's longing aligns with destiny."
            case .chinese: return "法性 + 愿力：责任与渴望的张力——内心渴望是否与天命一致。"
            case .hindi: return "धर्म + काम: कर्तव्य और इच्छा के बीच तनाव — जांचें कि आपकी हृदय की चाह नियति से मेल खाती है या नहीं।"
            }
        }
        if pair.contains(.dharma) && pair.contains(.moksha) {
            switch language {
            case .english: return "Dharma + Moksha: Fulfilling duty leads to spiritual breakthrough and awakening."
            case .chinese: return "法性 + 解脱：通过履行责任达到灵性突破，正法引向觉醒。"
            case .hindi: return "धर्म + मोक्ष: कर्तव्य पूर्ति आध्यात्मिक सफलता और जागृति की ओर ले जाती है।"
            }
        }
        if pair.contains(.karma) && pair.contains(.kama) {
            switch language {
            case .english: return "Karma + Kama: Examine whether your actions truly serve your deepest wishes."
            case .chinese: return "业果 + 愿力：行动是否在为真正的愿望服务，努力与心愿的互动正在展开。"
            case .hindi: return "कर्म + काम: जांचें कि क्या आपके कर्म वास्तव में आपकी गहरी इच्छाओं की सेवा कर रहे हैं।"
            }
        }
        if pair.contains(.karma) && pair.contains(.moksha) {
            switch language {
            case .english: return "Karma + Moksha: Persistent effort ultimately leads to spiritual elevation."
            case .chinese: return "业果 + 解脱：持续精进最终导向灵性升华，行动通往解脱。"
            case .hindi: return "कर्म + मोक्ष: निरंतर प्रयास अंततः आध्यात्मिक उन्नति की ओर ले जाता है।"
            }
        }
        if pair.contains(.kama) && pair.contains(.moksha) {
            switch language {
            case .english: return "Kama + Moksha: Transform worldly desire into spiritual pursuit — love becomes liberation."
            case .chinese: return "愿力 + 解脱：将世俗渴望转化为灵性追求，爱欲与超越交融。"
            case .hindi: return "काम + मोक्ष: सांसारिक इच्छा को आध्यात्मिक खोज में बदलें — प्रेम मुक्ति बन जाता है।"
            }
        }

        return nil
    }

    private func buildFullInterpretation(deityID: DeityID, language: AppLanguage) -> String {
        let deity = Deity.deity(for: deityID)
        var fullText = ""

        for drawn in drawnCards {
            let posName = drawn.position.localizedName(for: language)
            let cardName = drawn.card.localizedName(for: language)
            let cardMeaning = drawn.card.localizedMeaning(for: language)
            let suitName = drawn.card.suit.localizedName(for: language)
            let cardDesc = drawn.card.localizedDescription(for: language)

            switch language {
            case .english:
                fullText += "【\(posName)】\(cardName) (\(suitName))\n\(cardMeaning)\n\(cardDesc)\n\n"
            case .chinese:
                fullText += "【\(posName)】\(cardName)（\(suitName)）\n\(cardMeaning)\n\(cardDesc)\n\n"
            case .hindi:
                fullText += "【\(posName)】\(cardName) (\(suitName))\n\(cardMeaning)\n\(cardDesc)\n\n"
            }
        }

        if let insight = crossSuitInsight(language: language) {
            switch language {
            case .english: fullText += "✦ Cross-Dimension Insight ✦\n\(insight)\n\n"
            case .chinese: fullText += "✦ 跨维度洞察 ✦\n\(insight)\n\n"
            case .hindi: fullText += "✦ अंतर-आयाम अंतर्दृष्टि ✦\n\(insight)\n\n"
            }
        }

        let deityName = deity.localizedName(for: language)
        switch language {
        case .english:
            fullText += "✦ Oracle of \(deityName) ✦\nThe three cards together form a complete divine message. Trust in \(deityName)'s guidance and let this wisdom illuminate your path forward."
        case .chinese:
            fullText += "✦ \(deityName)神谕 ✦\n三张卡牌共同构成完整的神圣信息。信任\(deityName)的指引，让这份智慧照亮你前行的道路。"
        case .hindi:
            fullText += "✦ \(deityName) का दैवीय संदेश ✦\nतीनों कार्ड मिलकर एक पूर्ण दिव्य संदेश बनाते हैं। \(deityName) के मार्गदर्शन पर भरोसा रखें और इस ज्ञान को अपने आगे के मार्ग को प्रकाशित करने दें।"
        }

        return fullText
    }

    private func generateInterpretation(deityID: DeityID, language: AppLanguage) {
        isTypewriting = true
        let fullText = buildFullInterpretation(deityID: deityID, language: language)
        typewriteText(fullText)
    }

    private func typewriteText(_ text: String) {
        interpretationText = ""
        let chars = Array(text)
        Task {
            for (i, char) in chars.enumerated() {
                interpretationText.append(char)
                if i % 3 == 0 {
                    try? await Task.sleep(for: .milliseconds(15))
                }
            }
            isTypewriting = false
        }
    }

    private func fetchAIInterpretation(deityID: DeityID, language: AppLanguage) async {
        isLoadingAI = true
        aiError = nil
        aiInterpretation = ""

        let deity = Deity.deity(for: deityID)
        let deityName = deity.localizedName(for: language)

        let cardDetails = drawnCards.map { drawn -> String in
            let posName = drawn.position.localizedName(for: language)
            let cardName = drawn.card.localizedName(for: language)
            let suitName = drawn.card.suit.localizedName(for: language)
            let meaning = drawn.card.localizedMeaning(for: language)
            let desc = drawn.card.localizedDescription(for: language)
            return "[\(posName)] \(cardName) (\(suitName)) - \(meaning)\n\(desc)"
        }.joined(separator: "\n\n")

        let languageInstruction: String
        switch language {
        case .english:
            languageInstruction = "You MUST respond entirely in English."
        case .chinese:
            languageInstruction = "你必须完全用中文回答，不要出现任何英文。"
        case .hindi:
            languageInstruction = "आपको पूरी तरह से हिंदी में उत्तर देना होगा, कोई अंग्रेजी नहीं।"
        }

        let systemPrompt: String
        switch language {
        case .english:
            systemPrompt = """
            You are a divine oracle channeling the wisdom of \(deityName) from Hindu tradition. You provide profound, specific, and compassionate divination readings. \(languageInstruction) Your interpretation should be mystical yet practical, connecting the cards' spiritual meaning to the seeker's real-life situation. Structure your response with clear paragraphs. Be warm, wise, and insightful.
            """
        case .chinese:
            systemPrompt = """
            你是一位神圣的神谕者，传递印度教传统中\(deityName)的智慧。你提供深刻、具体、充满慈悲的占卜解读。\(languageInstruction) 你的解读应当神秘而实用，将卡牌的灵性含义与求问者的现实生活联系起来。请分段回答，语言温暖、智慧、有洞察力。
            """
        case .hindi:
            systemPrompt = """
            आप एक दिव्य ओरेकल हैं जो हिंदू परंपरा से \(deityName) की बुद्धि को प्रसारित करते हैं। आप गहन, विशिष्ट और करुणामय भविष्यवाणी पठन प्रदान करते हैं। \(languageInstruction) आपकी व्याख्या रहस्यमय लेकिन व्यावहारिक होनी चाहिए। स्पष्ट अनुच्छेदों में उत्तर दें।
            """
        }

        let userPrompt: String
        switch language {
        case .english:
            userPrompt = """
            The seeker asks: \(question.isEmpty ? "General life guidance" : question)

            Three cards drawn in the Trikal Darshan (Three Time Contemplation) spread:
            \(cardDetails)

            Please provide a personalized divine interpretation from \(deityName), addressing the seeker's question through each card's position (Origin/Past, Present, Future/Fruit). Weave the card meanings together into a cohesive spiritual narrative. End with specific, actionable guidance.
            """
        case .chinese:
            userPrompt = """
            求问者的问题：\(question.isEmpty ? "人生指引" : question)

            三时观照（Trikal Darshan）牌阵抽出的三张卡牌：
            \(cardDetails)

            请以\(deityName)的身份提供个性化的神圣解读，针对求问者的问题，通过每张卡牌的位置（根源/过去、当下/现在、果证/未来）进行解答。将三张卡牌的含义编织成一个连贯的灵性叙事。最后给出具体的、可操作的指引。
            """
        case .hindi:
            userPrompt = """
            साधक का प्रश्न: \(question.isEmpty ? "जीवन मार्गदर्शन" : question)

            त्रिकाल दर्शन में निकाले गए तीन कार्ड:
            \(cardDetails)

            कृपया \(deityName) के रूप में व्यक्तिगत दिव्य व्याख्या प्रदान करें। प्रत्येक कार्ड की स्थिति (मूल/भूत, वर्तमान, फल/भविष्य) के माध्यम से साधक के प्रश्न का उत्तर दें। अंत में विशिष्ट मार्गदर्शन दें।
            """
        }

        let messages: [DeepSeekMessage] = [
            DeepSeekMessage(role: "system", content: systemPrompt),
            DeepSeekMessage(role: "user", content: userPrompt)
        ]

        do {
            let stream = DeepSeekService.shared.streamChat(messages: messages)
            for try await chunk in stream {
                aiInterpretation += chunk
            }
        } catch {
            aiError = error.localizedDescription
            if aiInterpretation.isEmpty {
                aiInterpretation = buildFullInterpretation(deityID: deityID, language: language)
            }
        }
        isLoadingAI = false
    }

    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let decoded = try? JSONDecoder().decode([DivinationRecord].self, from: data) else { return }
        records = decoded
    }

    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }

    private func loadDeityReadStatus() {
        guard let data = UserDefaults.standard.data(forKey: deityReadKey),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data) else { return }
        deityReadStatus = decoded
    }

    private func saveDeityReadStatus() {
        if let data = try? JSONEncoder().encode(deityReadStatus) {
            UserDefaults.standard.set(data, forKey: deityReadKey)
        }
    }

    var timeUntilReset: String {
        let diff = nextResetDate.timeIntervalSinceNow
        guard diff > 0 else { return "00:00:00" }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

enum DivinationPhase {
    case input
    case shuffling
    case revealing
    case result
}
