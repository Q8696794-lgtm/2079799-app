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
        default:
            return []
        }
    }
}
