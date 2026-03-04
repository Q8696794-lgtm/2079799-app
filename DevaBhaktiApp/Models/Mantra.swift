import Foundation

nonisolated struct Mantra: Identifiable, Sendable {
    let id: String
    let sanskrit: String
    let transliteration: String
    let translationEN: String
    let translationZH: String
    let translationHI: String
    let deityID: DeityID
    let repetitions: Int

    func localizedTranslation(for language: AppLanguage) -> String {
        switch language {
        case .english: return translationEN
        case .chinese: return translationZH
        case .hindi: return translationHI
        }
    }

    static let shivaMantras: [Mantra] = [
        Mantra(id: "shiva_1", sanskrit: "ॐ नमः शिवाय", transliteration: "Om Namah Shivaya", translationEN: "I bow to Lord Shiva", translationZH: "我向湿婆主致敬", translationHI: "मैं भगवान शिव को नमन करता हूं", deityID: .shiva, repetitions: 108),
        Mantra(id: "shiva_2", sanskrit: "ॐ त्र्यम्बकं यजामहे", transliteration: "Om Tryambakam Yajamahe", translationEN: "We worship the three-eyed Lord Shiva", translationZH: "我们崇拜三眼湿婆主", translationHI: "हम त्रिनेत्र भगवान शिव की पूजा करते हैं", deityID: .shiva, repetitions: 108),
        Mantra(id: "shiva_3", sanskrit: "ॐ तत्पुरुषाय विद्महे", transliteration: "Om Tatpurushaya Vidmahe", translationEN: "We meditate upon the Supreme Being", translationZH: "我们冥想至高存在", translationHI: "हम परम पुरुष का ध्यान करते हैं", deityID: .shiva, repetitions: 108),
    ]

    static let hanumanMantras: [Mantra] = [
        Mantra(id: "hanuman_1", sanskrit: "ॐ हनुमते नमः", transliteration: "Om Hanumante Namaha", translationEN: "I bow to Lord Hanuman", translationZH: "我向哈努曼主致敬", translationHI: "मैं भगवान हनुमान को नमन करता हूं", deityID: .hanuman, repetitions: 108),
        Mantra(id: "hanuman_2", sanskrit: "ॐ अंजनेयाय नमः", transliteration: "Om Anjaneyaya Namaha", translationEN: "Salutations to the son of Anjana", translationZH: "向安贾纳之子致敬", translationHI: "अंजना के पुत्र को नमन", deityID: .hanuman, repetitions: 108),
        Mantra(id: "hanuman_3", sanskrit: "मनोजवं मारुततुल्यवेगम्", transliteration: "Manojavam Marutatulyavegam", translationEN: "Swift as the mind, fast as the wind", translationZH: "思维般敏捷，疾风般迅速", translationHI: "मन के समान तेज, वायु के समान गतिशील", deityID: .hanuman, repetitions: 108),
    ]

    static let ganeshaMantras: [Mantra] = [
        Mantra(id: "ganesha_1", sanskrit: "ॐ गं गणपतये नमः", transliteration: "Om Gam Ganapataye Namaha", translationEN: "I bow to Lord Ganesha", translationZH: "我向象头神致敬", translationHI: "मैं भगवान गणेश को नमन करता हूं", deityID: .ganesha, repetitions: 108),
        Mantra(id: "ganesha_2", sanskrit: "वक्रतुण्ड महाकाय", transliteration: "Vakratunda Mahakaya", translationEN: "O Lord with curved trunk and mighty body", translationZH: "弯鼻伟躯之主", translationHI: "टेढ़ी सूंड और विशाल शरीर वाले प्रभु", deityID: .ganesha, repetitions: 108),
        Mantra(id: "ganesha_3", sanskrit: "ॐ विघ्ननाशनाय नमः", transliteration: "Om Vighnanashanaya Namaha", translationEN: "Salutations to the destroyer of obstacles", translationZH: "向消除障碍者致敬", translationHI: "विघ्नों के नाशक को नमन", deityID: .ganesha, repetitions: 108),
    ]

    static let lakshmiMantras: [Mantra] = [
        Mantra(id: "lakshmi_1", sanskrit: "ॐ श्रीं महालक्ष्म्यै नमः", transliteration: "Om Shreem Mahalakshmiyei Namaha", translationEN: "I bow to Goddess Lakshmi", translationZH: "我向拉克什米女神致敬", translationHI: "मैं देवी लक्ष्मी को नमन करता हूं", deityID: .lakshmi, repetitions: 108),
        Mantra(id: "lakshmi_2", sanskrit: "ॐ ह्रीं श्रीं लक्ष्मीभ्यो नमः", transliteration: "Om Hreem Shreem Lakshmibhyo Namaha", translationEN: "Salutations to the auspicious Lakshmi", translationZH: "向吉祥的拉克什米致敬", translationHI: "शुभ लक्ष्मी को नमन", deityID: .lakshmi, repetitions: 108),
        Mantra(id: "lakshmi_3", sanskrit: "सर्वमंगल मांगल्ये", transliteration: "Sarvamangala Mangalye", translationEN: "O auspicious one who brings all that is good", translationZH: "带来一切美好的吉祥者", translationHI: "सभी मंगल लाने वाली शुभ देवी", deityID: .lakshmi, repetitions: 108),
    ]

    static let ramaMantras: [Mantra] = [
        Mantra(id: "rama_1", sanskrit: "श्री राम जय राम जय जय राम", transliteration: "Sri Ram Jai Ram Jai Jai Ram", translationEN: "Glory to Lord Rama", translationZH: "荣耀归于罗摩主", translationHI: "भगवान राम की जय", deityID: .rama, repetitions: 108),
        Mantra(id: "rama_2", sanskrit: "ॐ श्री रामाय नमः", transliteration: "Om Sri Ramaya Namaha", translationEN: "I bow to Lord Rama", translationZH: "我向罗摩主致敬", translationHI: "मैं भगवान राम को नमन करता हूं", deityID: .rama, repetitions: 108),
        Mantra(id: "rama_3", sanskrit: "रामो राजमणि सदा विजयते", transliteration: "Ramo Rajamani Sada Vijayate", translationEN: "Rama the jewel of kings always triumphs", translationZH: "帝王之宝罗摩永远胜利", translationHI: "राजाओं के रत्न राम सदा विजयी रहें", deityID: .rama, repetitions: 108),
    ]

    static let krishnaMantras: [Mantra] = [
        Mantra(id: "krishna_1", sanskrit: "हरे कृष्ण हरे कृष्ण", transliteration: "Hare Krishna Hare Krishna", translationEN: "O Lord Krishna, O energy of the Lord", translationZH: "奎师那主啊，主的能量啊", translationHI: "हे कृष्ण, हे भगवान की शक्ति", deityID: .krishna, repetitions: 108),
        Mantra(id: "krishna_2", sanskrit: "ॐ कृष्णाय नमः", transliteration: "Om Krishnaya Namaha", translationEN: "I bow to Lord Krishna", translationZH: "我向奎师那主致敬", translationHI: "मैं भगवान कृष्ण को नमन करता हूं", deityID: .krishna, repetitions: 108),
        Mantra(id: "krishna_3", sanskrit: "ॐ क्लीं कृष्णाय गोविंदाय", transliteration: "Om Kleem Krishnaya Govindaya", translationEN: "O Krishna, protector of cows and joy giver", translationZH: "奎师那啊，牛群的守护者与欢乐的赐予者", translationHI: "हे कृष्ण, गायों के रक्षक और आनंददाता", deityID: .krishna, repetitions: 108),
    ]

    static let vishnuMantras: [Mantra] = [
        Mantra(id: "vishnu_1", sanskrit: "ॐ नमो नारायणाय", transliteration: "Om Namo Narayanaya", translationEN: "I bow to Lord Narayana (Vishnu)", translationZH: "我向那罗延（毗湿奴）主致敬", translationHI: "मैं भगवान नारायण (विष्णु) को नमन करता हूं", deityID: .vishnu, repetitions: 108),
        Mantra(id: "vishnu_2", sanskrit: "ॐ नमो भगवते वासुदेवाय", transliteration: "Om Namo Bhagavate Vasudevaya", translationEN: "I bow to Lord Vasudeva", translationZH: "我向瓦苏德瓦主致敬", translationHI: "मैं भगवान वासुदेव को नमन करता हूं", deityID: .vishnu, repetitions: 108),
        Mantra(id: "vishnu_3", sanskrit: "शांताकारं भुजगशयनं", transliteration: "Shantakaram Bhujagashayanam", translationEN: "The peaceful one who rests on the serpent", translationZH: "安息于巨蛇之上的宁静之主", translationHI: "शांत स्वरूप जो शेषनाग पर विश्राम करते हैं", deityID: .vishnu, repetitions: 108),
    ]
}
