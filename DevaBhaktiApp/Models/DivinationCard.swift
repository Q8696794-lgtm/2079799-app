import Foundation

nonisolated enum CardSuit: String, Codable, CaseIterable, Sendable {
    case dharma
    case karma
    case kama
    case moksha

    var romanRange: String {
        switch self {
        case .dharma: return "I - VIII"
        case .karma: return "IX - XVI"
        case .kama: return "XVII - XXIV"
        case .moksha: return "XXV - XXXII"
        }
    }

    var icon: String {
        switch self {
        case .dharma: return "dharma.wheel"
        case .karma: return "arrow.trianglehead.2.clockwise"
        case .kama: return "lotus.fill"
        case .moksha: return "leaf.fill"
        }
    }

    var sfSymbol: String {
        switch self {
        case .dharma: return "circle.grid.cross.fill"
        case .karma: return "arrow.trianglehead.2.clockwise"
        case .kama: return "heart.fill"
        case .moksha: return "sparkle"
        }
    }

    func localizedName(for language: AppLanguage) -> String {
        switch self {
        case .dharma:
            switch language {
            case .english: return "Dharma"
            case .chinese: return "法性"
            case .hindi: return "धर्म"
            }
        case .karma:
            switch language {
            case .english: return "Karma"
            case .chinese: return "业果"
            case .hindi: return "कर्म"
            }
        case .kama:
            switch language {
            case .english: return "Kama"
            case .chinese: return "愿力"
            case .hindi: return "काम"
            }
        case .moksha:
            switch language {
            case .english: return "Moksha"
            case .chinese: return "解脱"
            case .hindi: return "मोक्ष"
            }
        }
    }

    func localizedMeaning(for language: AppLanguage) -> String {
        switch self {
        case .dharma:
            switch language {
            case .english: return "Righteousness, Duty, Moral Order"
            case .chinese: return "正法、责任、道德秩序"
            case .hindi: return "धार्मिकता, कर्तव्य, नैतिक व्यवस्था"
            }
        case .karma:
            switch language {
            case .english: return "Action, Effort, Cause & Effect"
            case .chinese: return "行动、努力、因果"
            case .hindi: return "कर्म, प्रयास, कारण और प्रभाव"
            }
        case .kama:
            switch language {
            case .english: return "Desire, Devotion, Emotion"
            case .chinese: return "愿望、奉爱、情感"
            case .hindi: return "इच्छा, भक्ति, भावना"
            }
        case .moksha:
            switch language {
            case .english: return "Liberation, Transcendence, Awakening"
            case .chinese: return "解脱、超越、觉醒"
            case .hindi: return "मुक्ति, उत्कर्ष, जागृति"
            }
        }
    }
}

nonisolated enum CardPosition: Int, Codable, CaseIterable, Sendable {
    case sthiti = 0
    case pravritti = 1
    case phala = 2

    func localizedName(for language: AppLanguage) -> String {
        switch self {
        case .sthiti:
            switch language {
            case .english: return "Sthiti · Origin"
            case .chinese: return "根源 Sthiti"
            case .hindi: return "स्थिति · मूल"
            }
        case .pravritti:
            switch language {
            case .english: return "Pravritti · Present"
            case .chinese: return "当下 Pravritti"
            case .hindi: return "प्रवृत्ति · वर्तमान"
            }
        case .phala:
            switch language {
            case .english: return "Phala · Fruit"
            case .chinese: return "果证 Phala"
            case .hindi: return "फल · परिणाम"
            }
        }
    }

    func localizedMeaning(for language: AppLanguage) -> String {
        switch self {
        case .sthiti:
            switch language {
            case .english: return "Hidden roots of your current situation, past karma and forgotten duties"
            case .chinese: return "当前处境的隐藏根源，过去种下的业因与被遗忘的愿力"
            case .hindi: return "वर्तमान स्थिति की छिपी जड़ें, पिछले कर्म और भूली हुई जिम्मेदारियां"
            }
        case .pravritti:
            switch language {
            case .english: return "Core energy of the present moment, your current strength and lessons"
            case .chinese: return "此刻局势的核心动力，你拥有的力量与需面对的功课"
            case .hindi: return "वर्तमान क्षण की मूल ऊर्जा, आपकी शक्ति और सबक"
            }
        case .phala:
            switch language {
            case .english: return "Direction of events, spiritual guidance and path corrections"
            case .chinese: return "事态走向与灵性教诲，指引行动方向或警示修正之路"
            case .hindi: return "घटनाओं की दिशा, आध्यात्मिक मार्गदर्शन और पथ सुधार"
            }
        }
    }
}

nonisolated struct DivinationCard: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let number: Int
    let suit: CardSuit
    let deityID: DeityID
    let nameEN: String
    let nameZH: String
    let nameHI: String
    let meaningEN: String
    let meaningZH: String
    let meaningHI: String
    let descEN: String
    let descZH: String
    let descHI: String

    var imageName: String {
        "card_\(deityID.rawValue)_\(number)"
    }

    var romanNumeral: String {
        let numerals = ["I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX","XXI","XXII","XXIII","XXIV","XXV","XXVI","XXVII","XXVIII","XXIX","XXX","XXXI","XXXII"]
        guard number >= 1, number <= 32 else { return "\(number)" }
        return numerals[number - 1]
    }

    func localizedName(for language: AppLanguage) -> String {
        switch language {
        case .english: return nameEN
        case .chinese: return nameZH
        case .hindi: return nameHI
        }
    }

    func localizedMeaning(for language: AppLanguage) -> String {
        switch language {
        case .english: return meaningEN
        case .chinese: return meaningZH
        case .hindi: return meaningHI
        }
    }

    func localizedDescription(for language: AppLanguage) -> String {
        switch language {
        case .english: return descEN
        case .chinese: return descZH
        case .hindi: return descHI
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DivinationCard, rhs: DivinationCard) -> Bool {
        lhs.id == rhs.id
    }
}

nonisolated struct DivinationRecord: Identifiable, Codable, Sendable {
    let id: String
    let date: Date
    let deityID: DeityID
    let question: String
    let cards: [DrawnCard]
    let interpretation: String

    var suitCombination: String {
        let suits = Set(cards.map(\.card.suit))
        if suits.count == 1 { return "triple_same" }
        return suits.map(\.rawValue).sorted().joined(separator: "+")
    }
}

nonisolated struct DrawnCard: Identifiable, Codable, Sendable {
    var id: String { card.id }
    let card: DivinationCard
    let position: CardPosition
}
