import SwiftUI

struct DivinationHistoryView: View {
    let records: [DivinationRecord]
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationService.self) private var loc
    @State private var expandedRecordID: String? = nil
    @State private var selectedCard: DivinationCard? = nil

    private let goldLight = Color(red: 1, green: 0.85, blue: 0.4)
    private let goldDark = Color(red: 0.85, green: 0.65, blue: 0.2)
    private let bgDark = Color(red: 0.06, green: 0.04, blue: 0.12)

    var body: some View {
        NavigationStack {
            ZStack {
                bgDark.ignoresSafeArea()

                if records.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(records) { record in
                                recordCard(record)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle(historyTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(loc.t(.done)) { dismiss() }
                        .foregroundStyle(goldLight)
                }
            }
            .sheet(item: $selectedCard) { card in
                HistoryCardDetailSheet(card: card, language: loc.currentLanguage)
            }
        }
    }

    private var historyTitle: String {
        switch loc.currentLanguage {
        case .english: return "Divination History"
        case .chinese: return "占卜历史"
        case .hindi: return "भविष्यवाणी इतिहास"
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 48))
                .foregroundStyle(goldLight.opacity(0.3))
            Text(emptyText)
                .font(.system(size: 15, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }

    private var emptyText: String {
        switch loc.currentLanguage {
        case .english: return "No divination records yet.\nBegin your first reading."
        case .chinese: return "暂无占卜记录\n开始你的第一次占卜"
        case .hindi: return "अभी तक कोई भविष्यवाणी रिकॉर्ड नहीं।\nअपनी पहली भविष्यवाणी शुरू करें।"
        }
    }

    private func recordCard(_ record: DivinationRecord) -> some View {
        let deity = Deity.deity(for: record.deityID)
        let isExpanded = expandedRecordID == record.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedRecordID = isExpanded ? nil : record.id
                }
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(deity.symbol)
                            .font(.system(size: 24))
                        Text(deity.localizedName(for: loc.currentLanguage))
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundStyle(goldLight)
                        Spacer()
                        Text(formatDate(record.date))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.3))
                    }

                    if !record.question.isEmpty {
                        Text(record.question)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    HStack(spacing: 8) {
                        ForEach(record.cards, id: \.card.id) { drawn in
                            HStack(spacing: 4) {
                                Image(systemName: drawn.card.suit.sfSymbol)
                                    .font(.system(size: 10))
                                    .foregroundStyle(suitColor(drawn.card.suit))
                                Text(drawn.card.localizedName(for: loc.currentLanguage))
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.06))
                            )
                        }
                    }
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 16) {
                    Divider().overlay(goldDark.opacity(0.2))

                    HStack(spacing: 8) {
                        ForEach(record.cards, id: \.card.id) { drawn in
                            historyCardTile(drawn: drawn, deityColor: deity.primaryColor)
                        }
                    }
                    .padding(.horizontal, 12)

                    if !record.interpretation.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "text.book.closed.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(goldLight)
                                Text(interpretationLabel)
                                    .font(.system(size: 13, weight: .bold, design: .serif))
                                    .foregroundStyle(goldLight)
                            }
                            Text(record.interpretation)
                                .font(.system(size: 12, weight: .regular, design: .serif))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(deity.primaryColor.opacity(isExpanded ? 0.3 : 0.15), lineWidth: 0.5)
                )
        )
    }

    private func historyCardTile(drawn: DrawnCard, deityColor: Color) -> some View {
        Button {
            selectedCard = drawn.card
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [deityColor.opacity(0.3), deityColor.opacity(0.08)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(goldDark.opacity(0.3), lineWidth: 1)
                        )

                    VStack(spacing: 2) {
                        Text(drawn.card.romanNumeral)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(goldLight.opacity(0.6))

                        if let uiImage = UIImage(named: drawn.card.imageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55, height: 65)
                                .clipShape(.rect(cornerRadius: 6))
                        }

                        Text(drawn.card.localizedName(for: loc.currentLanguage))
                            .font(.system(size: 8, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(4)
                }
                .frame(height: 110)

                Text(drawn.position.localizedName(for: loc.currentLanguage))
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(goldLight.opacity(0.7))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var interpretationLabel: String {
        switch loc.currentLanguage {
        case .english: return "Interpretation"
        case .chinese: return "解读"
        case .hindi: return "व्याख्या"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        switch loc.currentLanguage {
        case .english: formatter.locale = Locale(identifier: "en")
        case .chinese: formatter.locale = Locale(identifier: "zh")
        case .hindi: formatter.locale = Locale(identifier: "hi")
        }
        return formatter.string(from: date)
    }

    private func suitColor(_ suit: CardSuit) -> Color {
        switch suit {
        case .dharma: return .orange
        case .karma: return .red
        case .kama: return .pink
        case .moksha: return .cyan
        }
    }
}

struct HistoryCardDetailSheet: View {
    let card: DivinationCard
    let language: AppLanguage

    private let goldLight = Color(red: 1, green: 0.85, blue: 0.4)
    private let goldDark = Color(red: 0.85, green: 0.65, blue: 0.2)
    private let bgDark = Color(red: 0.06, green: 0.04, blue: 0.12)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                cardImageSection
                cardInfoSection
                descriptionSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .background(bgDark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var cardImageSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [suitColor.opacity(0.4), suitColor.opacity(0.1)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(colors: [goldLight.opacity(0.6), goldDark.opacity(0.3)], startPoint: .top, endPoint: .bottom),
                                lineWidth: 2
                            )
                    )

                VStack(spacing: 8) {
                    Text(card.romanNumeral)
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundStyle(goldLight.opacity(0.7))

                    if let uiImage = UIImage(named: card.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 260)
                            .clipShape(.rect(cornerRadius: 12))
                            .shadow(color: suitColor.opacity(0.5), radius: 12)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: card.suit.sfSymbol)
                            .font(.system(size: 12))
                            .foregroundStyle(suitColor)
                        Text(card.suit.localizedName(for: language))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(suitColor)
                    }
                }
                .padding(16)
            }
        }
    }

    private var cardInfoSection: some View {
        VStack(spacing: 8) {
            Text(card.localizedName(for: language))
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(goldLight)
                .multilineTextAlignment(.center)

            if language != .english {
                Text(card.nameEN)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text(card.localizedMeaning(for: language))
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 2)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.book.closed.fill")
                    .foregroundStyle(goldLight)
                Text(descTitle)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(goldLight)
            }

            Text(card.localizedDescription(for: language))
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(6)

            Divider().overlay(goldDark.opacity(0.2))

            HStack(spacing: 8) {
                Image(systemName: card.suit.sfSymbol)
                    .foregroundStyle(suitColor)
                Text(card.suit.localizedMeaning(for: language))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(goldDark.opacity(0.15), lineWidth: 0.5)
                )
        )
    }

    private var descTitle: String {
        switch language {
        case .english: return "Card Revelation"
        case .chinese: return "卡牌启示"
        case .hindi: return "कार्ड रहस्योद्घाटन"
        }
    }

    private var suitColor: Color {
        switch card.suit {
        case .dharma: return .orange
        case .karma: return .red
        case .kama: return .pink
        case .moksha: return .cyan
        }
    }
}
