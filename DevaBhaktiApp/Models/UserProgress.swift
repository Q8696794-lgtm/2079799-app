import Foundation

nonisolated struct UserProgress: Codable, Sendable {
    var punyaPoints: Int = 0
    var dailyDarshanStreak: Int = 0
    var lastDarshanDate: Date?
    var totalMantrasChanted: Int = 0
    var totalDarshanCount: Int = 0
    var level: DevotionLevel = .shishya
    var achievements: [String] = []

    var nextLevelProgress: Double {
        let thresholds: [DevotionLevel: Int] = [
            .shishya: 0,
            .sadhak: 500,
            .upasak: 2000,
            .bhakt: 5000,
            .paramBhakt: 15000,
        ]
        let currentThreshold = thresholds[level] ?? 0
        let allLevels = DevotionLevel.allCases
        guard let currentIndex = allLevels.firstIndex(of: level),
              currentIndex + 1 < allLevels.count else { return 1.0 }
        let nextThreshold = thresholds[allLevels[currentIndex + 1]] ?? 15000
        let range = nextThreshold - currentThreshold
        guard range > 0 else { return 1.0 }
        return min(1.0, Double(punyaPoints - currentThreshold) / Double(range))
    }
}

nonisolated enum DevotionLevel: String, Codable, CaseIterable, Sendable {
    case shishya = "Shishya"
    case sadhak = "Sadhak"
    case upasak = "Upasak"
    case bhakt = "Bhakt"
    case paramBhakt = "Param Bhakt"

    var displayName: String { rawValue }

    func localizedName(for language: AppLanguage) -> String {
        switch self {
        case .shishya:
            switch language {
            case .english: return "Shishya"
            case .chinese: return "弟子"
            case .hindi: return "शिष्य"
            }
        case .sadhak:
            switch language {
            case .english: return "Sadhak"
            case .chinese: return "求道者"
            case .hindi: return "साधक"
            }
        case .upasak:
            switch language {
            case .english: return "Upasak"
            case .chinese: return "崇拜者"
            case .hindi: return "उपासक"
            }
        case .bhakt:
            switch language {
            case .english: return "Bhakt"
            case .chinese: return "信徒"
            case .hindi: return "भक्त"
            }
        case .paramBhakt:
            switch language {
            case .english: return "Param Bhakt"
            case .chinese: return "至高信徒"
            case .hindi: return "परम भक्त"
            }
        }
    }

    var icon: String {
        switch self {
        case .shishya: return "leaf.fill"
        case .sadhak: return "flame.fill"
        case .upasak: return "sun.max.fill"
        case .bhakt: return "star.fill"
        case .paramBhakt: return "crown.fill"
        }
    }
}
