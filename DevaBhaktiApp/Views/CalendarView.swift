import SwiftUI

struct CalendarView: View {
    @Environment(AppState.self) private var appState
    @Environment(LocalizationService.self) private var loc
    @State private var selectedDate = Date()

    private var hinduFestivals: [(name: String, deity: DeityID?, date: String, description: String)] {
        [
            (loc.t(.festMahaShivaratri), .shiva, "Feb/Mar", loc.t(.festMahaShivaratriDesc)),
            (loc.t(.festGaneshChaturthi), .ganesha, "Aug/Sep", loc.t(.festGaneshChaturthiDesc)),
            (loc.t(.festDiwali), .lakshmi, "Oct/Nov", loc.t(.festDiwaliDesc)),
            (loc.t(.festJanmashtami), .krishna, "Aug/Sep", loc.t(.festJanmashtamiDesc)),
            (loc.t(.festRamNavami), .rama, "Mar/Apr", loc.t(.festRamNavamiDesc)),
            (loc.t(.festHanumanJayanti), .hanuman, "Apr", loc.t(.festHanumanJayantiDesc)),
            (loc.t(.festVaikunthaEkadashi), .vishnu, "Dec/Jan", loc.t(.festVaikunthaEkadashiDesc)),
            (loc.t(.festNavaratri), nil, "Sep/Oct", loc.t(.festNavaratriDesc)),
            (loc.t(.festHoli), .krishna, "Mar", loc.t(.festHoliDesc)),
            (loc.t(.festKartikPurnima), .vishnu, "Nov", loc.t(.festKartikPurnimaDesc)),
        ]
    }

    private var sacredDays: [(dayKey: String, day: String, deity: String, description: String)] {
        [
            ("Monday", loc.t(.monday), "🔱 \(Deity.deity(for: .shiva).localizedName(for: loc.currentLanguage))", loc.t(.sacredMonday)),
            ("Tuesday", loc.t(.tuesday), "🐒 \(Deity.deity(for: .hanuman).localizedName(for: loc.currentLanguage))", loc.t(.sacredTuesday)),
            ("Wednesday", loc.t(.wednesday), "🐘 \(Deity.deity(for: .ganesha).localizedName(for: loc.currentLanguage)) / 🪈 \(Deity.deity(for: .krishna).localizedName(for: loc.currentLanguage))", loc.t(.sacredWednesday)),
            ("Thursday", loc.t(.thursday), "🏹 \(Deity.deity(for: .rama).localizedName(for: loc.currentLanguage)) / 🪬 \(Deity.deity(for: .vishnu).localizedName(for: loc.currentLanguage))", loc.t(.sacredThursday)),
            ("Friday", loc.t(.friday), "🪷 \(Deity.deity(for: .lakshmi).localizedName(for: loc.currentLanguage))", loc.t(.sacredFriday)),
            ("Saturday", loc.t(.saturday), "—", loc.t(.sacredSaturday)),
            ("Sunday", loc.t(.sunday), "—", loc.t(.sacredSunday)),
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.04, blue: 0.12)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        todayCard
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        sacredDaysSection
                            .padding(.horizontal, 16)

                        festivalsSection
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(loc.t(.panchang))
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var todayCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date(), style: .date)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    Text(localizedDayOfWeek)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                }
                Spacer()
                Text("ॐ")
                    .font(.system(size: 36))
                    .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4).opacity(0.6))
            }

            if let todaySacred = sacredDays.first(where: { $0.dayKey == dayOfWeekEnglish }) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkle")
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                    Text("\(loc.t(.todaysDeity)): \(todaySacred.deity)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                }
            }

            HStack(spacing: 16) {
                timeBlock(title: loc.t(.sunrise), time: "6:12 AM", icon: "sunrise.fill")
                timeBlock(title: loc.t(.sunset), time: "6:28 PM", icon: "sunset.fill")
                timeBlock(title: loc.t(.rahuKaal), time: "3:00 PM", icon: "exclamationmark.triangle.fill")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.15, green: 0.10, blue: 0.25), Color(red: 0.10, green: 0.07, blue: 0.18)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.2), lineWidth: 0.5)
                )
        )
    }

    private func timeBlock(title: String, time: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.orange)
            Text(time)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private var sacredDaysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.t(.sacredDaysOfWeek))
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

            ForEach(sacredDays, id: \.dayKey) { item in
                HStack(spacing: 12) {
                    Text(item.day)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 80, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.deity)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                        Text(item.description)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.4))
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(item.dayKey == dayOfWeekEnglish ? Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.1) : .clear)
                )
            }
        }
    }

    private var festivalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.t(.hinduFestivals))
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))

            ForEach(hinduFestivals, id: \.name) { festival in
                HStack(spacing: 14) {
                    if let deityID = festival.deity {
                        Text(Deity.deity(for: deityID).symbol)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(Deity.deity(for: deityID).primaryColor.opacity(0.2))
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.15))
                            .clipShape(Circle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(festival.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            Spacer()
                            Text(festival.date)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                        }
                        Text(festival.description)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(2)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(0.04))
                )
            }
        }
    }

    private var dayOfWeekEnglish: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    private var localizedDayOfWeek: String {
        let english = dayOfWeekEnglish
        let dayMap: [String: LocalizedKey] = [
            "Monday": .monday, "Tuesday": .tuesday, "Wednesday": .wednesday,
            "Thursday": .thursday, "Friday": .friday, "Saturday": .saturday, "Sunday": .sunday,
        ]
        if let key = dayMap[english] {
            return loc.t(key)
        }
        return english
    }
}
