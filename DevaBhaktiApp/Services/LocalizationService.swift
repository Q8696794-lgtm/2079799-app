import SwiftUI

nonisolated enum AppLanguage: String, Codable, CaseIterable, Sendable {
    case english = "en"
    case chinese = "zh"
    case hindi = "hi"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        case .hindi: return "हिन्दी"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .chinese: return "🇨🇳"
        case .hindi: return "🇮🇳"
        }
    }
}

@Observable
@MainActor
class LocalizationService {
    var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: "appLanguage"),
           let lang = AppLanguage(rawValue: raw) {
            self.currentLanguage = lang
        } else {
            self.currentLanguage = .english
        }
    }

    func t(_ key: LocalizedKey) -> String {
        key.text(for: currentLanguage)
    }
}

nonisolated enum LocalizedKey: Sendable {
    case devaBhakti
    case divineDevtoion
    case chooseYourGuardians
    case selectDeities
    case selected
    case confirmSelection
    case beginYourJourney
    case maxDeitiesAllowed
    case ishtaDevata
    case welcomePhilosophy
    case welcomePhilosophySub
    case chooseYourDeity
    case darshan
    case mantras
    case divination
    case calendar
    case profile
    case dailyDarshan
    case receiveBlessings
    case darshanComplete
    case virtualAarti
    case lightSacredFlame
    case sacredOffering
    case dailyBlessing
    case streak
    case punya
    case totalMantrasChanted
    case lifetime
    case malas
    case chant
    case malaComplete
    case namaste
    case drawCard
    case drawDivineCard
    case drawAgain
    case meaning
    case divineGuidance
    case panchang
    case sacredDaysOfWeek
    case hinduFestivals
    case todaysDeity
    case sunrise
    case sunset
    case rahuKaal
    case devotionProgress
    case yourGuardians
    case statistics
    case achievements
    case settings
    case resetProgress
    case resetWarning
    case cancel
    case reset
    case devotee
    case primary
    case language
    case darshanStreak
    case totalDarshanLabel
    case mantrasChantedLabel
    case malasComplete
    case firstDarshan
    case sevenDayStreak
    case mantras108
    case mantras1000
    case sadhakLevel
    case thirtyDayStreak
    case done
    case aartiFor
    case aartiInstruction
    case offeringFor
    case reps
    case card
    case followers
    case ofCount
    case tap
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    case festMahaShivaratri
    case festGaneshChaturthi
    case festDiwali
    case festJanmashtami
    case festRamNavami
    case festHanumanJayanti
    case festVaikunthaEkadashi
    case festNavaratri
    case festHoli
    case festKartikPurnima
    case festMahaShivaratriDesc
    case festGaneshChaturthiDesc
    case festDiwaliDesc
    case festJanmashtamiDesc
    case festRamNavamiDesc
    case festHanumanJayantiDesc
    case festVaikunthaEkadashiDesc
    case festNavaratriDesc
    case festHoliDesc
    case festKartikPurnimaDesc
    case sacredMonday
    case sacredTuesday
    case sacredWednesday
    case sacredThursday
    case sacredFriday
    case sacredSaturday
    case sacredSunday

    func text(for language: AppLanguage) -> String {
        switch self {
        case .devaBhakti:
            switch language {
            case .english: return "Deva Bhakti"
            case .chinese: return "天神信仰"
            case .hindi: return "देव भक्ति"
            }
        case .divineDevtoion:
            switch language {
            case .english: return "Divine Devotion"
            case .chinese: return "神圣的奉献"
            case .hindi: return "दिव्य भक्ति"
            }
        case .chooseYourGuardians:
            switch language {
            case .english: return "Choose Your Guardians"
            case .chinese: return "选择你的守护神"
            case .hindi: return "अपने आराध्य चुनें"
            }
        case .selectDeities:
            switch language {
            case .english: return "Select 1-3 Deities"
            case .chinese: return "选择1-3位主神"
            case .hindi: return "1-3 देवता चुनें"
            }
        case .selected:
            switch language {
            case .english: return "Selected"
            case .chinese: return "已选择"
            case .hindi: return "चयनित"
            }
        case .confirmSelection:
            switch language {
            case .english: return "Confirm Selection"
            case .chinese: return "确认选择"
            case .hindi: return "चयन की पुष्टि करें"
            }
        case .beginYourJourney:
            switch language {
            case .english: return "Begin Your Journey"
            case .chinese: return "开启你的修行之旅"
            case .hindi: return "अपनी यात्रा शुरू करें"
            }
        case .maxDeitiesAllowed:
            switch language {
            case .english: return "Maximum 3 deities allowed"
            case .chinese: return "最多可选择3位主神"
            case .hindi: return "अधिकतम 3 देवता चुन सकते हैं"
            }
        case .ishtaDevata:
            switch language {
            case .english: return "Ishta Devata"
            case .chinese: return "本尊神"
            case .hindi: return "इष्ट देवता"
            }
        case .welcomePhilosophy:
            switch language {
            case .english: return "In Hindu tradition, every soul has a deity whose energy resonates with their innermost being — your Ishta Devata, your chosen divine."
            case .chinese: return "在印度教传统中，每个灵魂都有一位与其内心深处产生共鸣的神明——你的本尊神，你选择的神圣存在。"
            case .hindi: return "हिंदू परंपरा में, हर आत्मा का एक देवता होता है जिसकी ऊर्जा उसके अंतरतम से गूंजती है — आपके इष्ट देवता।"
            }
        case .welcomePhilosophySub:
            switch language {
            case .english: return "Every soul has a deity that resonates with their innermost being"
            case .chinese: return "每个灵魂都有一位与其内心深处产生共鸣的神明"
            case .hindi: return "हर आत्मा का एक देवता होता है जो उसके अंतरतम से गूंजता है"
            }
        case .chooseYourDeity:
            switch language {
            case .english: return "Choose Your Deity"
            case .chinese: return "选择你的神明"
            case .hindi: return "अपने देवता चुनें"
            }
        case .darshan:
            switch language {
            case .english: return "Darshan"
            case .chinese: return "神见"
            case .hindi: return "दर्शन"
            }
        case .mantras:
            switch language {
            case .english: return "Mantras"
            case .chinese: return "真言"
            case .hindi: return "मंत्र"
            }
        case .divination:
            switch language {
            case .english: return "Divination"
            case .chinese: return "占卜"
            case .hindi: return "भविष्यवाणी"
            }
        case .calendar:
            switch language {
            case .english: return "Calendar"
            case .chinese: return "历法"
            case .hindi: return "पंचांग"
            }
        case .profile:
            switch language {
            case .english: return "Profile"
            case .chinese: return "个人"
            case .hindi: return "प्रोफ़ाइल"
            }
        case .dailyDarshan:
            switch language {
            case .english: return "Daily Darshan"
            case .chinese: return "每日神见"
            case .hindi: return "दैनिक दर्शन"
            }
        case .receiveBlessings:
            switch language {
            case .english: return "Receive divine blessings"
            case .chinese: return "接受神圣的祝福"
            case .hindi: return "दिव्य आशीर्वाद प्राप्त करें"
            }
        case .darshanComplete:
            switch language {
            case .english: return "Darshan Complete ✓"
            case .chinese: return "神见完成 ✓"
            case .hindi: return "दर्शन पूर्ण ✓"
            }
        case .virtualAarti:
            switch language {
            case .english: return "Virtual Aarti"
            case .chinese: return "虚拟灯祭"
            case .hindi: return "आभासी आरती"
            }
        case .lightSacredFlame:
            switch language {
            case .english: return "Light the sacred flame"
            case .chinese: return "点燃神圣之火"
            case .hindi: return "पवित्र ज्योति जलाएं"
            }
        case .sacredOffering:
            switch language {
            case .english: return "Sacred Offering"
            case .chinese: return "神圣供品"
            case .hindi: return "पवित्र अर्पण"
            }
        case .dailyBlessing:
            switch language {
            case .english: return "Daily Blessing"
            case .chinese: return "每日祝福"
            case .hindi: return "दैनिक आशीर्वाद"
            }
        case .streak:
            switch language {
            case .english: return "Streak"
            case .chinese: return "连续"
            case .hindi: return "लगातार"
            }
        case .punya:
            switch language {
            case .english: return "Punya"
            case .chinese: return "功德"
            case .hindi: return "पुण्य"
            }
        case .totalMantrasChanted:
            switch language {
            case .english: return "Total Mantras Chanted"
            case .chinese: return "累计念诵真言"
            case .hindi: return "कुल मंत्र जाप"
            }
        case .lifetime:
            switch language {
            case .english: return "Lifetime"
            case .chinese: return "终身"
            case .hindi: return "आजीवन"
            }
        case .malas:
            switch language {
            case .english: return "malas"
            case .chinese: return "圈念珠"
            case .hindi: return "माला"
            }
        case .chant:
            switch language {
            case .english: return "Chant"
            case .chinese: return "念诵"
            case .hindi: return "जाप"
            }
        case .malaComplete:
            switch language {
            case .english: return "Mala Complete!"
            case .chinese: return "念珠完成！"
            case .hindi: return "माला पूर्ण!"
            }
        case .namaste:
            switch language {
            case .english: return "Namaste 🙏"
            case .chinese: return "合十 🙏"
            case .hindi: return "नमस्ते 🙏"
            }
        case .drawCard:
            switch language {
            case .english: return "Draw a card from"
            case .chinese: return "抽取卡牌"
            case .hindi: return "कार्ड निकालें"
            }
        case .drawDivineCard:
            switch language {
            case .english: return "Draw Divine Card"
            case .chinese: return "抽取神圣卡牌"
            case .hindi: return "दिव्य कार्ड निकालें"
            }
        case .drawAgain:
            switch language {
            case .english: return "Draw Again"
            case .chinese: return "再次抽取"
            case .hindi: return "फिर से निकालें"
            }
        case .meaning:
            switch language {
            case .english: return "Meaning"
            case .chinese: return "含义"
            case .hindi: return "अर्थ"
            }
        case .divineGuidance:
            switch language {
            case .english: return "Divine Guidance"
            case .chinese: return "神圣指引"
            case .hindi: return "दिव्य मार्गदर्शन"
            }
        case .panchang:
            switch language {
            case .english: return "Panchang"
            case .chinese: return "印度历法"
            case .hindi: return "पंचांग"
            }
        case .sacredDaysOfWeek:
            switch language {
            case .english: return "Sacred Days of the Week"
            case .chinese: return "一周圣日"
            case .hindi: return "सप्ताह के पवित्र दिन"
            }
        case .hinduFestivals:
            switch language {
            case .english: return "Hindu Festivals"
            case .chinese: return "印度教节日"
            case .hindi: return "हिंदू त्योहार"
            }
        case .todaysDeity:
            switch language {
            case .english: return "Today's deity"
            case .chinese: return "今日主神"
            case .hindi: return "आज के देवता"
            }
        case .sunrise:
            switch language {
            case .english: return "Sunrise"
            case .chinese: return "日出"
            case .hindi: return "सूर्योदय"
            }
        case .sunset:
            switch language {
            case .english: return "Sunset"
            case .chinese: return "日落"
            case .hindi: return "सूर्यास्त"
            }
        case .rahuKaal:
            switch language {
            case .english: return "Rahu Kaal"
            case .chinese: return "罗睺时"
            case .hindi: return "राहु काल"
            }
        case .devotionProgress:
            switch language {
            case .english: return "Devotion Progress"
            case .chinese: return "修行进度"
            case .hindi: return "भक्ति प्रगति"
            }
        case .yourGuardians:
            switch language {
            case .english: return "Your Guardians"
            case .chinese: return "你的守护神"
            case .hindi: return "आपके आराध्य"
            }
        case .statistics:
            switch language {
            case .english: return "Statistics"
            case .chinese: return "统计数据"
            case .hindi: return "आंकड़े"
            }
        case .achievements:
            switch language {
            case .english: return "Achievements"
            case .chinese: return "成就"
            case .hindi: return "उपलब्धियां"
            }
        case .settings:
            switch language {
            case .english: return "Settings"
            case .chinese: return "设置"
            case .hindi: return "सेटिंग्स"
            }
        case .resetProgress:
            switch language {
            case .english: return "Reset Progress"
            case .chinese: return "重置进度"
            case .hindi: return "प्रगति रीसेट करें"
            }
        case .resetWarning:
            switch language {
            case .english: return "This will reset all your devotion progress. This action cannot be undone."
            case .chinese: return "这将重置你所有的修行进度。此操作无法撤销。"
            case .hindi: return "यह आपकी सभी भक्ति प्रगति को रीसेट कर देगा। यह क्रिया पूर्ववत नहीं की जा सकती।"
            }
        case .cancel:
            switch language {
            case .english: return "Cancel"
            case .chinese: return "取消"
            case .hindi: return "रद्द करें"
            }
        case .reset:
            switch language {
            case .english: return "Reset"
            case .chinese: return "重置"
            case .hindi: return "रीसेट"
            }
        case .devotee:
            switch language {
            case .english: return "Devotee"
            case .chinese: return "信徒"
            case .hindi: return "भक्त"
            }
        case .primary:
            switch language {
            case .english: return "Primary"
            case .chinese: return "主尊"
            case .hindi: return "प्रमुख"
            }
        case .language:
            switch language {
            case .english: return "Language"
            case .chinese: return "语言"
            case .hindi: return "भाषा"
            }
        case .darshanStreak:
            switch language {
            case .english: return "Darshan Streak"
            case .chinese: return "神见连续"
            case .hindi: return "दर्शन लगातार"
            }
        case .totalDarshanLabel:
            switch language {
            case .english: return "Total Darshan"
            case .chinese: return "总神见"
            case .hindi: return "कुल दर्शन"
            }
        case .mantrasChantedLabel:
            switch language {
            case .english: return "Mantras Chanted"
            case .chinese: return "已念真言"
            case .hindi: return "मंत्र जाप"
            }
        case .malasComplete:
            switch language {
            case .english: return "Malas Complete"
            case .chinese: return "念珠圈数"
            case .hindi: return "माला पूर्ण"
            }
        case .firstDarshan:
            switch language {
            case .english: return "First Darshan"
            case .chinese: return "首次神见"
            case .hindi: return "प्रथम दर्शन"
            }
        case .sevenDayStreak:
            switch language {
            case .english: return "7-Day Streak"
            case .chinese: return "7天连续"
            case .hindi: return "7 दिन लगातार"
            }
        case .mantras108:
            switch language {
            case .english: return "108 Mantras"
            case .chinese: return "108真言"
            case .hindi: return "108 मंत्र"
            }
        case .mantras1000:
            switch language {
            case .english: return "1000 Mantras"
            case .chinese: return "1000真言"
            case .hindi: return "1000 मंत्र"
            }
        case .sadhakLevel:
            switch language {
            case .english: return "Sadhak Level"
            case .chinese: return "求道者等级"
            case .hindi: return "साधक स्तर"
            }
        case .thirtyDayStreak:
            switch language {
            case .english: return "30-Day Streak"
            case .chinese: return "30天连续"
            case .hindi: return "30 दिन लगातार"
            }
        case .done:
            switch language {
            case .english: return "Done"
            case .chinese: return "完成"
            case .hindi: return "पूर्ण"
            }
        case .aartiFor:
            switch language {
            case .english: return "Aarti for"
            case .chinese: return "灯祭献给"
            case .hindi: return "आरती"
            }
        case .aartiInstruction:
            switch language {
            case .english: return "Swipe the flame in circular motion\nto perform the sacred Aarti ritual"
            case .chinese: return "以圆形手势滑动火焰\n进行神圣的灯祭仪式"
            case .hindi: return "पवित्र आरती अनुष्ठान करने के लिए\nज्योति को गोलाकार गति में घुमाएं"
            }
        case .offeringFor:
            switch language {
            case .english: return "Traditional offering for"
            case .chinese: return "传统供品献给"
            case .hindi: return "पारंपरिक अर्पण"
            }
        case .reps:
            switch language {
            case .english: return "reps"
            case .chinese: return "次"
            case .hindi: return "बार"
            }
        case .card:
            switch language {
            case .english: return "Card"
            case .chinese: return "卡牌"
            case .hindi: return "कार्ड"
            }
        case .followers:
            switch language {
            case .english: return "followers"
            case .chinese: return "信徒"
            case .hindi: return "अनुयायी"
            }
        case .ofCount:
            switch language {
            case .english: return "of"
            case .chinese: return "/"
            case .hindi: return "में से"
            }
        case .tap:
            switch language {
            case .english: return "TAP"
            case .chinese: return "点击"
            case .hindi: return "टैप"
            }
        case .monday:
            switch language {
            case .english: return "Monday"
            case .chinese: return "星期一"
            case .hindi: return "सोमवार"
            }
        case .tuesday:
            switch language {
            case .english: return "Tuesday"
            case .chinese: return "星期二"
            case .hindi: return "मंगलवार"
            }
        case .wednesday:
            switch language {
            case .english: return "Wednesday"
            case .chinese: return "星期三"
            case .hindi: return "बुधवार"
            }
        case .thursday:
            switch language {
            case .english: return "Thursday"
            case .chinese: return "星期四"
            case .hindi: return "गुरुवार"
            }
        case .friday:
            switch language {
            case .english: return "Friday"
            case .chinese: return "星期五"
            case .hindi: return "शुक्रवार"
            }
        case .saturday:
            switch language {
            case .english: return "Saturday"
            case .chinese: return "星期六"
            case .hindi: return "शनिवार"
            }
        case .sunday:
            switch language {
            case .english: return "Sunday"
            case .chinese: return "星期日"
            case .hindi: return "रविवार"
            }
        case .festMahaShivaratri:
            switch language {
            case .english: return "Maha Shivaratri"
            case .chinese: return "摩诃湿婆夜"
            case .hindi: return "महा शिवरात्रि"
            }
        case .festGaneshChaturthi:
            switch language {
            case .english: return "Ganesh Chaturthi"
            case .chinese: return "象头神节"
            case .hindi: return "गणेश चतुर्थी"
            }
        case .festDiwali:
            switch language {
            case .english: return "Diwali"
            case .chinese: return "排灯节"
            case .hindi: return "दिवाली"
            }
        case .festJanmashtami:
            switch language {
            case .english: return "Janmashtami"
            case .chinese: return "黑天诞辰"
            case .hindi: return "जन्माष्टमी"
            }
        case .festRamNavami:
            switch language {
            case .english: return "Ram Navami"
            case .chinese: return "罗摩诞辰"
            case .hindi: return "राम नवमी"
            }
        case .festHanumanJayanti:
            switch language {
            case .english: return "Hanuman Jayanti"
            case .chinese: return "哈努曼诞辰"
            case .hindi: return "हनुमान जयंती"
            }
        case .festVaikunthaEkadashi:
            switch language {
            case .english: return "Vaikuntha Ekadashi"
            case .chinese: return "毗恭达十一日"
            case .hindi: return "वैकुंठ एकादशी"
            }
        case .festNavaratri:
            switch language {
            case .english: return "Navaratri"
            case .chinese: return "九夜节"
            case .hindi: return "नवरात्रि"
            }
        case .festHoli:
            switch language {
            case .english: return "Holi"
            case .chinese: return "洒红节"
            case .hindi: return "होली"
            }
        case .festKartikPurnima:
            switch language {
            case .english: return "Kartik Purnima"
            case .chinese: return "迦提克满月"
            case .hindi: return "कार्तिक पूर्णिमा"
            }
        case .festMahaShivaratriDesc:
            switch language {
            case .english: return "The great night of Lord Shiva, dedicated to worship and meditation"
            case .chinese: return "湿婆主的伟大之夜，致力于崇拜与冥想"
            case .hindi: return "भगवान शिव की महान रात्रि, पूजा और ध्यान को समर्पित"
            }
        case .festGaneshChaturthiDesc:
            switch language {
            case .english: return "Birthday of Lord Ganesha, celebrated with grand festivities"
            case .chinese: return "象头神的诞辰，以盛大庆典庆祝"
            case .hindi: return "भगवान गणेश का जन्मदिन, भव्य उत्सव के साथ मनाया जाता है"
            }
        case .festDiwaliDesc:
            switch language {
            case .english: return "Festival of lights, worship of Goddess Lakshmi for prosperity"
            case .chinese: return "灯节，崇拜拉克什米女神以求繁荣"
            case .hindi: return "रोशनी का त्योहार, समृद्धि के लिए देवी लक्ष्मी की पूजा"
            }
        case .festJanmashtamiDesc:
            switch language {
            case .english: return "Birthday of Lord Krishna, celebrated with dance and devotion"
            case .chinese: return "黑天的诞辰，以舞蹈与虔诚庆祝"
            case .hindi: return "भगवान कृष्ण का जन्मदिन, नृत्य और भक्ति के साथ मनाया जाता है"
            }
        case .festRamNavamiDesc:
            switch language {
            case .english: return "Birthday of Lord Rama, celebrated with prayers and fasting"
            case .chinese: return "罗摩的诞辰，以祈祷与斋戒庆祝"
            case .hindi: return "भगवान राम का जन्मदिन, प्रार्थना और उपवास के साथ मनाया जाता है"
            }
        case .festHanumanJayantiDesc:
            switch language {
            case .english: return "Birthday of Lord Hanuman, celebrating strength and devotion"
            case .chinese: return "哈努曼的诞辰，庆祝力量与奉献"
            case .hindi: return "भगवान हनुमान का जन्मदिन, शक्ति और भक्ति का उत्सव"
            }
        case .festVaikunthaEkadashiDesc:
            switch language {
            case .english: return "The most auspicious Ekadashi dedicated to Lord Vishnu"
            case .chinese: return "献给毗湿奴主的最吉祥的十一日"
            case .hindi: return "भगवान विष्णु को समर्पित सबसे शुभ एकादशी"
            }
        case .festNavaratriDesc:
            switch language {
            case .english: return "Nine nights of worship celebrating the Divine Feminine"
            case .chinese: return "崇拜神圣女性力量的九个夜晚"
            case .hindi: return "दिव्य स्त्री शक्ति का उत्सव मनाने वाली नौ रातें"
            }
        case .festHoliDesc:
            switch language {
            case .english: return "Festival of colors, celebrating divine love of Radha and Krishna"
            case .chinese: return "色彩节，庆祝拉达与奎师那的神圣之爱"
            case .hindi: return "रंगों का त्योहार, राधा और कृष्ण के दिव्य प्रेम का उत्सव"
            }
        case .festKartikPurnimaDesc:
            switch language {
            case .english: return "Sacred full moon, dedicated to Lord Vishnu and Shiva"
            case .chinese: return "神圣的满月，献给毗湿奴与湿婆主"
            case .hindi: return "पवित्र पूर्णिमा, भगवान विष्णु और शिव को समर्पित"
            }
        case .sacredMonday:
            switch language {
            case .english: return "Worship Lord Shiva with Bilva leaves and milk abhishekam"
            case .chinese: return "以比尔瓦叶和牛奶灌浴崇拜湿婆主"
            case .hindi: return "बिल्व पत्र और दूध अभिषेक से भगवान शिव की पूजा करें"
            }
        case .sacredTuesday:
            switch language {
            case .english: return "Recite Hanuman Chalisa, offer sindoor and jasmine"
            case .chinese: return "诵念哈努曼四十颂，供奉朱砂与茉莉"
            case .hindi: return "हनुमान चालीसा पढ़ें, सिंदूर और चमेली अर्पित करें"
            }
        case .sacredWednesday:
            switch language {
            case .english: return "Worship Ganesha for new beginnings, Krishna for wisdom"
            case .chinese: return "崇拜象头神以求新的开始，崇拜奎师那以求智慧"
            case .hindi: return "नई शुरुआत के लिए गणेश की पूजा, ज्ञान के लिए कृष्ण की पूजा"
            }
        case .sacredThursday:
            switch language {
            case .english: return "Worship Vishnu and Rama, wear yellow garments"
            case .chinese: return "崇拜毗湿奴与罗摩，穿黄色衣服"
            case .hindi: return "विष्णु और राम की पूजा करें, पीले वस्त्र पहनें"
            }
        case .sacredFriday:
            switch language {
            case .english: return "Worship Goddess Lakshmi, light ghee lamps"
            case .chinese: return "崇拜拉克什米女神，点燃酥油灯"
            case .hindi: return "देवी लक्ष्मी की पूजा करें, घी के दीपक जलाएं"
            }
        case .sacredSaturday:
            switch language {
            case .english: return "Worship Shani Dev, practice austerity"
            case .chinese: return "崇拜沙尼天神，修行苦行"
            case .hindi: return "शनि देव की पूजा करें, तपस्या का अभ्यास करें"
            }
        case .sacredSunday:
            switch language {
            case .english: return "Surya worship, offer water to the Sun"
            case .chinese: return "崇拜太阳神，向太阳供水"
            case .hindi: return "सूर्य पूजा, सूर्य को जल अर्पित करें"
            }
        }
    }
}
