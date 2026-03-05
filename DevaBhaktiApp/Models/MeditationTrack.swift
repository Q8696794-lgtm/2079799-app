import SwiftUI

nonisolated struct MeditationTrack: Identifiable, Sendable {
    let id: String
    let nameEN: String
    let nameZH: String
    let nameHI: String
    let descEN: String
    let descZH: String
    let descHI: String
    let durationMinutes: Int
    let frequency: Double
    let harmonicFrequency: Double
    let icon: String
    let deityID: DeityID

    func localizedName(for language: AppLanguage) -> String {
        switch language {
        case .english: return nameEN
        case .chinese: return nameZH
        case .hindi: return nameHI
        }
    }

    func localizedDesc(for language: AppLanguage) -> String {
        switch language {
        case .english: return descEN
        case .chinese: return descZH
        case .hindi: return descHI
        }
    }

    static func tracks(for deity: DeityID) -> [MeditationTrack] {
        switch deity {
        case .shiva:
            return [
                MeditationTrack(id: "shiva_1", nameEN: "Cosmic Stillness", nameZH: "宇宙寂静", nameHI: "ब्रह्मांडीय शांति", descEN: "Deep meditation on the eternal silence of Shiva", descZH: "深入冥想湿婆的永恒寂静", descHI: "शिव की शाश्वत शांति पर गहन ध्यान", durationMinutes: 10, frequency: 136.1, harmonicFrequency: 272.2, icon: "moon.stars.fill", deityID: .shiva),
                MeditationTrack(id: "shiva_2", nameEN: "Third Eye Awakening", nameZH: "天眼觉醒", nameHI: "तृतीय नेत्र जागरण", descEN: "Focus on the Ajna chakra with Shiva's energy", descZH: "以湿婆的能量聚焦于眉心轮", descHI: "शिव की ऊर्जा से आज्ञा चक्र पर ध्यान", durationMinutes: 15, frequency: 144.0, harmonicFrequency: 288.0, icon: "eye.fill", deityID: .shiva),
                MeditationTrack(id: "shiva_3", nameEN: "Nataraja Dance", nameZH: "宇宙之舞", nameHI: "नटराज नृत्य", descEN: "Rhythmic meditation on creation and dissolution", descZH: "关于创造与毁灭的节奏冥想", descHI: "सृष्टि और विलय पर लयबद्ध ध्यान", durationMinutes: 20, frequency: 141.27, harmonicFrequency: 211.44, icon: "figure.dance", deityID: .shiva),
                MeditationTrack(id: "shiva_4", nameEN: "Mount Kailash Peace", nameZH: "凯拉什山之宁", nameHI: "कैलाश पर्वत शांति", descEN: "Visualize the sacred mountain in deep tranquility", descZH: "在深度宁静中观想圣山", descHI: "गहन शांति में पवित्र पर्वत का ध्यान", durationMinutes: 30, frequency: 128.0, harmonicFrequency: 256.0, icon: "mountain.2.fill", deityID: .shiva),
            ]
        case .hanuman:
            return [
                MeditationTrack(id: "hanuman_1", nameEN: "Courage Meditation", nameZH: "勇气冥想", nameHI: "साहस ध्यान", descEN: "Draw strength from Hanuman's fearless devotion", descZH: "从哈努曼无畏的奉献中汲取力量", descHI: "हनुमान की निर्भय भक्ति से शक्ति प्राप्त करें", durationMinutes: 10, frequency: 150.0, harmonicFrequency: 300.0, icon: "bolt.heart.fill", deityID: .hanuman),
                MeditationTrack(id: "hanuman_2", nameEN: "Devotion Focus", nameZH: "奉献专注", nameHI: "भक्ति ध्यान", descEN: "Meditate on selfless service and devotion", descZH: "冥想无私的服务与奉献", descHI: "निःस्वार्थ सेवा और भक्ति पर ध्यान", durationMinutes: 15, frequency: 146.0, harmonicFrequency: 219.0, icon: "heart.fill", deityID: .hanuman),
                MeditationTrack(id: "hanuman_3", nameEN: "Sacred Strength", nameZH: "神圣力量", nameHI: "पवित्र शक्ति", descEN: "Channel inner power through Hanuman's grace", descZH: "通过哈努曼的恩典引导内在力量", descHI: "हनुमान की कृपा से आंतरिक शक्ति का संचार", durationMinutes: 20, frequency: 155.0, harmonicFrequency: 232.5, icon: "flame.fill", deityID: .hanuman),
                MeditationTrack(id: "hanuman_4", nameEN: "Ram Naam Prayer", nameZH: "罗摩名祈祷", nameHI: "राम नाम प्रार्थना", descEN: "Silent prayer repeating the holy name of Rama", descZH: "默默祈祷重复罗摩的圣名", descHI: "राम के पवित्र नाम का मौन जाप", durationMinutes: 30, frequency: 140.0, harmonicFrequency: 210.0, icon: "hands.and.sparkles.fill", deityID: .hanuman),
            ]
        case .ganesha:
            return [
                MeditationTrack(id: "ganesha_1", nameEN: "Obstacle Clearing", nameZH: "清除障碍", nameHI: "विघ्न निवारण", descEN: "Release all blocks with Ganesha's blessing", descZH: "以象头神的祝福释放所有障碍", descHI: "गणेश के आशीर्वाद से सभी बाधाएं दूर करें", durationMinutes: 10, frequency: 138.0, harmonicFrequency: 276.0, icon: "sparkle", deityID: .ganesha),
                MeditationTrack(id: "ganesha_2", nameEN: "New Beginnings", nameZH: "新的开始", nameHI: "नई शुरुआत", descEN: "Meditate on fresh starts and new possibilities", descZH: "冥想新的起点与无限可能", descHI: "नई शुरुआत और संभावनाओं पर ध्यान", durationMinutes: 15, frequency: 141.0, harmonicFrequency: 211.5, icon: "sunrise.fill", deityID: .ganesha),
                MeditationTrack(id: "ganesha_3", nameEN: "Wisdom Light", nameZH: "智慧之光", nameHI: "ज्ञान प्रकाश", descEN: "Invoke Ganesha's wisdom for clarity of mind", descZH: "祈请象头神的智慧以澄明心灵", descHI: "मन की स्पष्टता के लिए गणेश की बुद्धि का आवाहन", durationMinutes: 20, frequency: 144.0, harmonicFrequency: 216.0, icon: "lightbulb.fill", deityID: .ganesha),
                MeditationTrack(id: "ganesha_4", nameEN: "Sacred Om Meditation", nameZH: "神圣唵字冥想", nameHI: "पवित्र ॐ ध्यान", descEN: "Deep Om chanting meditation with Ganesha", descZH: "与象头神一起的深度唵字念诵冥想", descHI: "गणेश के साथ गहन ॐ जाप ध्यान", durationMinutes: 30, frequency: 136.1, harmonicFrequency: 272.2, icon: "waveform.circle.fill", deityID: .ganesha),
            ]
        case .lakshmi:
            return [
                MeditationTrack(id: "lakshmi_1", nameEN: "Abundance Flow", nameZH: "丰盛之流", nameHI: "समृद्धि प्रवाह", descEN: "Open to the flow of divine abundance", descZH: "开启神圣丰盛的流动", descHI: "दिव्य समृद्धि के प्रवाह को खोलें", durationMinutes: 10, frequency: 132.0, harmonicFrequency: 264.0, icon: "drop.fill", deityID: .lakshmi),
                MeditationTrack(id: "lakshmi_2", nameEN: "Lotus Visualization", nameZH: "莲花观想", nameHI: "कमल ध्यान", descEN: "Visualize a golden lotus blooming in your heart", descZH: "观想一朵金色莲花在心中绽放", descHI: "अपने हृदय में सुनहरे कमल को खिलते हुए देखें", durationMinutes: 15, frequency: 135.0, harmonicFrequency: 202.5, icon: "leaf.fill", deityID: .lakshmi),
                MeditationTrack(id: "lakshmi_3", nameEN: "Inner Prosperity", nameZH: "内在繁荣", nameHI: "आंतरिक संपन्नता", descEN: "Cultivate inner wealth and spiritual richness", descZH: "培养内在财富与精神丰富", descHI: "आंतरिक संपदा और आध्यात्मिक समृद्धि का विकास", durationMinutes: 20, frequency: 139.0, harmonicFrequency: 208.5, icon: "sparkles", deityID: .lakshmi),
                MeditationTrack(id: "lakshmi_4", nameEN: "Divine Grace Prayer", nameZH: "神圣恩典祈祷", nameHI: "दिव्य कृपा प्रार्थना", descEN: "Prayerful meditation on Lakshmi's boundless grace", descZH: "对拉克什米无尽恩典的祈祷冥想", descHI: "लक्ष्मी की असीम कृपा पर प्रार्थना ध्यान", durationMinutes: 30, frequency: 130.0, harmonicFrequency: 260.0, icon: "hands.and.sparkles.fill", deityID: .lakshmi),
            ]
        case .rama:
            return [
                MeditationTrack(id: "rama_1", nameEN: "Dharma Path", nameZH: "正法之路", nameHI: "धर्म मार्ग", descEN: "Walk the path of righteousness with Rama", descZH: "与罗摩一起走正义之路", descHI: "राम के साथ धर्म के मार्ग पर चलें", durationMinutes: 10, frequency: 140.0, harmonicFrequency: 280.0, icon: "arrow.right.circle.fill", deityID: .rama),
                MeditationTrack(id: "rama_2", nameEN: "Peace of Ayodhya", nameZH: "阿约提亚之宁", nameHI: "अयोध्या की शांति", descEN: "Experience the peaceful kingdom of Rama", descZH: "体验罗摩和平的王国", descHI: "राम के शांतिपूर्ण राज्य का अनुभव", durationMinutes: 15, frequency: 137.0, harmonicFrequency: 205.5, icon: "building.columns.fill", deityID: .rama),
                MeditationTrack(id: "rama_3", nameEN: "Forest Retreat", nameZH: "森林静修", nameHI: "वन प्रवास", descEN: "Meditate in the sacred forests of exile", descZH: "在神圣的流放森林中冥想", descHI: "वनवास के पवित्र वनों में ध्यान", durationMinutes: 20, frequency: 134.0, harmonicFrequency: 201.0, icon: "tree.fill", deityID: .rama),
                MeditationTrack(id: "rama_4", nameEN: "Victory of Light", nameZH: "光明的胜利", nameHI: "प्रकाश की विजय", descEN: "Celebrate the triumph of good over evil", descZH: "庆祝善对恶的胜利", descHI: "बुराई पर अच्छाई की जीत का उत्सव", durationMinutes: 30, frequency: 142.0, harmonicFrequency: 213.0, icon: "sun.max.fill", deityID: .rama),
            ]
        case .krishna:
            return [
                MeditationTrack(id: "krishna_1", nameEN: "Divine Flute", nameZH: "神圣笛声", nameHI: "दिव्य बांसुरी", descEN: "Listen to Krishna's enchanting flute in your heart", descZH: "在心中聆听奎师那迷人的笛声", descHI: "अपने हृदय में कृष्ण की मोहक बांसुरी सुनें", durationMinutes: 10, frequency: 146.83, harmonicFrequency: 220.0, icon: "music.note", deityID: .krishna),
                MeditationTrack(id: "krishna_2", nameEN: "Gita Contemplation", nameZH: "薄伽梵歌沉思", nameHI: "गीता चिंतन", descEN: "Reflect on the wisdom of the Bhagavad Gita", descZH: "沉思薄伽梵歌的智慧", descHI: "भगवद गीता की बुद्धि पर चिंतन", durationMinutes: 15, frequency: 139.0, harmonicFrequency: 208.5, icon: "book.fill", deityID: .krishna),
                MeditationTrack(id: "krishna_3", nameEN: "Love & Devotion", nameZH: "爱与奉献", nameHI: "प्रेम और भक्ति", descEN: "Open your heart to divine love", descZH: "向神圣之爱敞开心扉", descHI: "दिव्य प्रेम के लिए अपना हृदय खोलें", durationMinutes: 20, frequency: 143.0, harmonicFrequency: 214.5, icon: "heart.circle.fill", deityID: .krishna),
                MeditationTrack(id: "krishna_4", nameEN: "Vrindavan Garden", nameZH: "温达文花园", nameHI: "वृंदावन उद्यान", descEN: "Peaceful visualization of Krishna's sacred garden", descZH: "奎师那神圣花园的宁静观想", descHI: "कृष्ण के पवित्र उद्यान का शांत ध्यान", durationMinutes: 30, frequency: 136.1, harmonicFrequency: 204.15, icon: "leaf.circle.fill", deityID: .krishna),
            ]
        case .vishnu:
            return [
                MeditationTrack(id: "vishnu_1", nameEN: "Cosmic Harmony", nameZH: "宇宙和谐", nameHI: "ब्रह्मांडीय सामंजस्य", descEN: "Tune into the preserving energy of the universe", descZH: "调谐宇宙的守护能量", descHI: "ब्रह्मांड की संरक्षक ऊर्जा से जुड़ें", durationMinutes: 10, frequency: 131.0, harmonicFrequency: 262.0, icon: "infinity.circle.fill", deityID: .vishnu),
                MeditationTrack(id: "vishnu_2", nameEN: "Ocean of Milk", nameZH: "乳海冥想", nameHI: "क्षीर सागर", descEN: "Float on the cosmic ocean of Vishnu", descZH: "漂浮在毗湿奴的宇宙之海上", descHI: "विष्णु के ब्रह्मांडीय सागर पर तैरें", durationMinutes: 15, frequency: 128.0, harmonicFrequency: 192.0, icon: "water.waves", deityID: .vishnu),
                MeditationTrack(id: "vishnu_3", nameEN: "Preservation Prayer", nameZH: "守护祈祷", nameHI: "संरक्षण प्रार्थना", descEN: "Pray for protection and cosmic balance", descZH: "为保护与宇宙平衡祈祷", descHI: "सुरक्षा और ब्रह्मांडीय संतुलन के लिए प्रार्थना", durationMinutes: 20, frequency: 135.0, harmonicFrequency: 202.5, icon: "shield.fill", deityID: .vishnu),
                MeditationTrack(id: "vishnu_4", nameEN: "Ananta Shesha Rest", nameZH: "无尽蛇神安息", nameHI: "अनंत शेष विश्राम", descEN: "Deep rest meditation on the cosmic serpent", descZH: "在宇宙蛇神上的深度休息冥想", descHI: "ब्रह्मांडीय सर्प पर गहन विश्राम ध्यान", durationMinutes: 30, frequency: 126.0, harmonicFrequency: 189.0, icon: "moon.zzz.fill", deityID: .vishnu),
            ]
        }
    }
}
