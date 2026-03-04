import SwiftUI

nonisolated enum DeityID: String, Codable, CaseIterable, Sendable, Identifiable {
    case shiva
    case hanuman
    case ganesha
    case lakshmi
    case rama
    case krishna
    case vishnu

    var id: String { rawValue }
}

nonisolated struct Deity: Identifiable, Sendable {
    let id: DeityID
    let nameEnglish: String
    let nameChinese: String
    let nameHindi: String
    let symbol: String
    let sfSymbol: String
    let primaryColor: Color
    let secondaryColor: Color
    let followerCount: Int
    let descriptionEN: String
    let descriptionZH: String
    let descriptionHI: String
    let blessingEN: String
    let blessingZH: String
    let blessingHI: String
    let sacredDay: String
    let offeringEN: String
    let offeringZH: String
    let offeringHI: String
    let heroImageAsset: String
    let heroImageURL: URL?
    let mantras: [Mantra]
    let cardDivination: [DivinationCard]

    func localizedName(for language: AppLanguage) -> String {
        switch language {
        case .english: return nameEnglish
        case .chinese: return nameChinese
        case .hindi: return nameHindi
        }
    }

    func localizedDescription(for language: AppLanguage) -> String {
        switch language {
        case .english: return descriptionEN
        case .chinese: return descriptionZH
        case .hindi: return descriptionHI
        }
    }

    func localizedBlessing(for language: AppLanguage) -> String {
        switch language {
        case .english: return blessingEN
        case .chinese: return blessingZH
        case .hindi: return blessingHI
        }
    }

    func localizedOffering(for language: AppLanguage) -> String {
        switch language {
        case .english: return offeringEN
        case .chinese: return offeringZH
        case .hindi: return offeringHI
        }
    }

    static let allDeities: [Deity] = [
        Deity(
            id: .shiva,
            nameEnglish: "Shiva",
            nameChinese: "湿婆",
            nameHindi: "शिव",
            symbol: "🔱",
            sfSymbol: "flame.fill",
            primaryColor: Color(red: 0.28, green: 0.35, blue: 0.65),
            secondaryColor: Color(red: 0.45, green: 0.55, blue: 0.85),
            followerCount: 128743,
            descriptionEN: "The Destroyer and Transformer, Lord of Meditation and Cosmic Dance",
            descriptionZH: "毁灭与转化之神，冥想与宇宙之舞之主",
            descriptionHI: "विनाशक और परिवर्तक, ध्यान और ब्रह्मांडीय नृत्य के स्वामी",
            blessingEN: "Om Namah Shivaya — May Lord Shiva's grace dissolve all obstacles and lead you to supreme consciousness.",
            blessingZH: "唵那摩湿婆耶——愿湿婆主的恩典化解一切障碍，引领你走向至高意识。",
            blessingHI: "ॐ नमः शिवाय — भगवान शिव की कृपा सभी बाधाओं को दूर करे और आपको परम चेतना की ओर ले जाए।",
            sacredDay: "Monday",
            offeringEN: "Bilva Leaves",
            offeringZH: "比尔瓦叶",
            offeringHI: "बिल्व पत्र",
            heroImageAsset: "shiva_hero",
            heroImageURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/etzhf06gjcntqedskhw2d"),
            mantras: Mantra.shivaMantras,
            cardDivination: DivinationCard.allCards(for: .shiva)
        ),
        Deity(
            id: .hanuman,
            nameEnglish: "Hanuman",
            nameChinese: "哈努曼",
            nameHindi: "हनुमान",
            symbol: "🐒",
            sfSymbol: "bolt.fill",
            primaryColor: Color(red: 0.85, green: 0.45, blue: 0.15),
            secondaryColor: Color(red: 0.95, green: 0.65, blue: 0.25),
            followerCount: 95621,
            descriptionEN: "The Divine Devotee, embodiment of strength, courage and selfless service",
            descriptionZH: "神圣的信徒，力量、勇气与无私奉献的化身",
            descriptionHI: "दिव्य भक्त, शक्ति, साहस और निःस्वार्थ सेवा के अवतार",
            blessingEN: "Om Hanumante Namaha — May Hanuman's boundless devotion and strength shield you from all fear.",
            blessingZH: "唵哈努曼特那摩诃——愿哈努曼无尽的奉献与力量庇护你远离一切恐惧。",
            blessingHI: "ॐ हनुमते नमः — हनुमान जी की असीम भक्ति और शक्ति आपको सभी भय से बचाए।",
            sacredDay: "Tuesday",
            offeringEN: "Sindoor & Jasmine",
            offeringZH: "朱砂与茉莉",
            offeringHI: "सिंदूर और चमेली",
            heroImageAsset: "hanuman_hero",
            heroImageURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/5n0fc3xim1rhp6b8nqs45"),
            mantras: Mantra.hanumanMantras,
            cardDivination: DivinationCard.allCards(for: .hanuman)
        ),
        Deity(
            id: .ganesha,
            nameEnglish: "Ganesha",
            nameChinese: "象头神",
            nameHindi: "गणेश",
            symbol: "🐘",
            sfSymbol: "star.fill",
            primaryColor: Color(red: 0.85, green: 0.35, blue: 0.25),
            secondaryColor: Color(red: 0.95, green: 0.55, blue: 0.35),
            followerCount: 156892,
            descriptionEN: "Remover of Obstacles, Lord of Beginnings and Wisdom",
            descriptionZH: "消除障碍之神，启始与智慧之主",
            descriptionHI: "विघ्नहर्ता, आरंभ और बुद्धि के स्वामी",
            blessingEN: "Om Gam Ganapataye Namaha — May Ganesha clear your path and bless every new beginning.",
            blessingZH: "唵甘伽纳帕塔耶那摩诃——愿象头神为你扫清道路，祝福每一个新的开始。",
            blessingHI: "ॐ गं गणपतये नमः — गणेश जी आपका मार्ग प्रशस्त करें और हर नई शुरुआत को आशीर्वाद दें।",
            sacredDay: "Wednesday",
            offeringEN: "Modak & Durva Grass",
            offeringZH: "莫达克甜点与杜瓦草",
            offeringHI: "मोदक और दूर्वा घास",
            heroImageAsset: "ganesha_hero",
            heroImageURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/lm8ye2utotsjm3pnf6mmh"),
            mantras: Mantra.ganeshaMantras,
            cardDivination: DivinationCard.allCards(for: .ganesha)
        ),
        Deity(
            id: .lakshmi,
            nameEnglish: "Lakshmi",
            nameChinese: "拉克什米",
            nameHindi: "लक्ष्मी",
            symbol: "🪷",
            sfSymbol: "sparkles",
            primaryColor: Color(red: 0.85, green: 0.65, blue: 0.15),
            secondaryColor: Color(red: 0.95, green: 0.80, blue: 0.30),
            followerCount: 112340,
            descriptionEN: "Goddess of Wealth, Fortune, Love and Beauty",
            descriptionZH: "财富、命运、爱与美的女神",
            descriptionHI: "धन, भाग्य, प्रेम और सौंदर्य की देवी",
            blessingEN: "Om Shreem Mahalakshmiyei Namaha — May Lakshmi shower you with abundance and inner prosperity.",
            blessingZH: "唵施利摩诃拉克什米耶那摩诃——愿拉克什米赐予你丰盛与内在的繁荣。",
            blessingHI: "ॐ श्रीं महालक्ष्म्यै नमः — लक्ष्मी जी आप पर समृद्धि और आंतरिक संपन्नता की वर्षा करें।",
            sacredDay: "Friday",
            offeringEN: "Lotus & Red Flowers",
            offeringZH: "莲花与红色花朵",
            offeringHI: "कमल और लाल फूल",
            heroImageAsset: "lakshmi_hero",
            heroImageURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/oyje0veyrzl6ym4w8z7c3"),
            mantras: Mantra.lakshmiMantras,
            cardDivination: DivinationCard.allCards(for: .lakshmi)
        ),
        Deity(
            id: .rama,
            nameEnglish: "Rama",
            nameChinese: "罗摩",
            nameHindi: "राम",
            symbol: "🏹",
            sfSymbol: "shield.fill",
            primaryColor: Color(red: 0.15, green: 0.55, blue: 0.35),
            secondaryColor: Color(red: 0.25, green: 0.70, blue: 0.50),
            followerCount: 87432,
            descriptionEN: "The Ideal King, embodiment of Dharma and Righteousness",
            descriptionZH: "理想的帝王，正法与正义的化身",
            descriptionHI: "आदर्श राजा, धर्म और धार्मिकता के अवतार",
            blessingEN: "Sri Ram Jai Ram Jai Jai Ram — May Lord Rama's righteousness guide your every step on the path of dharma.",
            blessingZH: "斯利罗摩胜利罗摩——愿罗摩主的正义引导你在正法之路上的每一步。",
            blessingHI: "श्री राम जय राम जय जय राम — भगवान राम की धार्मिकता धर्म के मार्ग पर आपके हर कदम का मार्गदर्शन करे।",
            sacredDay: "Thursday",
            offeringEN: "Tulsi Leaves",
            offeringZH: "圣罗勒叶",
            offeringHI: "तुलसी पत्र",
            heroImageAsset: "rama_hero",
            heroImageURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/7eb61h106fqed6uc5chs8"),
            mantras: Mantra.ramaMantras,
            cardDivination: DivinationCard.allCards(for: .rama)
        ),
        Deity(
            id: .krishna,
            nameEnglish: "Krishna",
            nameChinese: "黑天",
            nameHindi: "कृष्ण",
            symbol: "🪈",
            sfSymbol: "music.note",
            primaryColor: Color(red: 0.15, green: 0.30, blue: 0.75),
            secondaryColor: Color(red: 0.30, green: 0.50, blue: 0.90),
            followerCount: 143567,
            descriptionEN: "The Divine Charmer, Lord of Love and the Bhagavad Gita",
            descriptionZH: "神圣的迷人之主，爱与薄伽梵歌之主",
            descriptionHI: "दिव्य मनमोहक, प्रेम और भगवद गीता के स्वामी",
            blessingEN: "Hare Krishna Hare Krishna — May Krishna's flute song awaken divine love in your heart.",
            blessingZH: "哈瑞奎师那哈瑞奎师那——愿奎师那的笛声唤醒你心中的神圣之爱。",
            blessingHI: "हरे कृष्ण हरे कृष्ण — कृष्ण की बांसुरी की धुन आपके हृदय में दिव्य प्रेम जगाए।",
            sacredDay: "Wednesday",
            offeringEN: "Tulsi & Butter",
            offeringZH: "圣罗勒与黄油",
            offeringHI: "तुलसी और मक्खन",
            heroImageAsset: "krishna_hero",
            heroImageURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/ndjuyf22c6t001z1cu9c1"),
            mantras: Mantra.krishnaMantras,
            cardDivination: DivinationCard.allCards(for: .krishna)
        ),
        Deity(
            id: .vishnu,
            nameEnglish: "Vishnu",
            nameChinese: "毗湿奴",
            nameHindi: "विष्णु",
            symbol: "🪬",
            sfSymbol: "infinity",
            primaryColor: Color(red: 0.10, green: 0.25, blue: 0.55),
            secondaryColor: Color(red: 0.20, green: 0.40, blue: 0.75),
            followerCount: 98765,
            descriptionEN: "The Preserver, sustainer of the cosmic order",
            descriptionZH: "守护之神，宇宙秩序的维护者",
            descriptionHI: "पालनकर्ता, ब्रह्मांडीय व्यवस्था के संरक्षक",
            blessingEN: "Om Namo Narayanaya — May Vishnu's divine protection preserve peace and harmony in your life.",
            blessingZH: "唵那摩那罗延那耶——愿毗湿奴的神圣庇护为你的生活维系和平与和谐。",
            blessingHI: "ॐ नमो नारायणाय — विष्णु भगवान की दिव्य सुरक्षा आपके जीवन में शांति और सामंजस्य बनाए रखे।",
            sacredDay: "Thursday",
            offeringEN: "Tulsi & Yellow Flowers",
            offeringZH: "圣罗勒与黄色花朵",
            offeringHI: "तुलसी और पीले फूल",
            heroImageAsset: "vishnu_hero",
            heroImageURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/bgqnf1xbnelpekjn8fspj"),
            mantras: Mantra.vishnuMantras,
            cardDivination: DivinationCard.allCards(for: .vishnu)
        ),
    ]

    static func deity(for id: DeityID) -> Deity {
        allDeities.first { $0.id == id }!
    }
}
