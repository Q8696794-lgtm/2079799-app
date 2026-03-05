import SwiftUI

nonisolated struct HymnTrack: Identifiable, Sendable {
    let id: String
    let nameEN: String
    let nameZH: String
    let nameHI: String
    let descEN: String
    let descZH: String
    let descHI: String
    let icon: String
    let audioURL: URL?
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

    static func hymns(for deity: DeityID) -> [HymnTrack] {
        switch deity {
        case .shiva:
            return [
                HymnTrack(
                    id: "shiva_hymn_1",
                    nameEN: "Shiva Hymn (Peaceful)",
                    nameZH: "湿婆赞歌（宁静）",
                    nameHI: "शिव स्तुति (शांत)",
                    descEN: "A serene hymn praising Lord Shiva's eternal tranquility",
                    descZH: "赞美湿婆永恒宁静的祥和赞歌",
                    descHI: "भगवान शिव की शाश्वत शांति की स्तुति",
                    icon: "music.note.house.fill",
                    audioURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/z2h2vk4kbsi0uyzytnqwp"),
                    deityID: .shiva
                ),
                HymnTrack(
                    id: "shiva_hymn_2",
                    nameEN: "Shiva Hymn (Passionate)",
                    nameZH: "湿婆赞歌（热忱）",
                    nameHI: "शिव स्तुति (उत्साही)",
                    descEN: "A passionate devotional hymn invoking Shiva's cosmic power",
                    descZH: "唤起湿婆宇宙力量的热忱奉献赞歌",
                    descHI: "शिव की ब्रह्मांडीय शक्ति का आवाहन करती भावपूर्ण स्तुति",
                    icon: "music.mic.circle.fill",
                    audioURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/v83njrexyvh9udlg9pjnb"),
                    deityID: .shiva
                ),
            ]
        case .krishna:
            return [
                HymnTrack(
                    id: "krishna_hymn_1",
                    nameEN: "Sri Krishna Mahamantra Stuti",
                    nameZH: "黑天大真言赞颂",
                    nameHI: "श्रीकृष्ण महामन्त्र स्तुतिः",
                    descEN: "A sacred hymn chanting the great mantra of Lord Krishna",
                    descZH: "吟唱奎师那大真言的神圣赞歌",
                    descHI: "भगवान कृष्ण के महामन्त्र की पवित्र स्तुति",
                    icon: "music.note.house.fill",
                    audioURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/5ll3ct0ku704uqmx6x4p8"),
                    deityID: .krishna
                ),
                HymnTrack(
                    id: "krishna_hymn_2",
                    nameEN: "Sri Krishna Stuti",
                    nameZH: "黑天赞颂",
                    nameHI: "श्रीकृष्ण स्तुतिः",
                    descEN: "A devotional hymn praising the glory of Lord Krishna",
                    descZH: "赞美奎师那荣耀的奉献赞歌",
                    descHI: "भगवान कृष्ण की महिमा की भक्तिपूर्ण स्तुति",
                    icon: "music.mic.circle.fill",
                    audioURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/vb6iorfyr9xiggvdvxujk"),
                    deityID: .krishna
                ),
            ]
        case .hanuman:
            return [
                HymnTrack(
                    id: "hanuman_hymn_1",
                    nameEN: "Hanuman Chalisa",
                    nameZH: "哈努曼四十颂",
                    nameHI: "हनुमान चालीसा",
                    descEN: "The sacred forty verses praising Lord Hanuman's glory",
                    descZH: "赞美哈努曼荣耀的神圣四十颂",
                    descHI: "भगवान हनुमान की महिमा के पवित्र चालीस छंद",
                    icon: "music.note.house.fill",
                    audioURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/yg91mcv17mz5uka9pp8w9"),
                    deityID: .hanuman
                ),
                HymnTrack(
                    id: "hanuman_hymn_2",
                    nameEN: "Hanuman Chalisa (Version 2)",
                    nameZH: "哈努曼四十颂（版本二）",
                    nameHI: "हनुमान चालीसा (संस्करण २)",
                    descEN: "Another beautiful rendition of the Hanuman Chalisa",
                    descZH: "哈努曼四十颂的另一优美版本",
                    descHI: "हनुमान चालीसा की एक और सुंदर प्रस्तुति",
                    icon: "music.mic.circle.fill",
                    audioURL: URL(string: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/j9oda9fxca32susgapmrx"),
                    deityID: .hanuman
                ),
            ]
        default:
            return []
        }
    }
}
