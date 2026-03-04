import SwiftUI

struct CardGalleryView: View {
    let deityID: DeityID
    let deityColor: Color
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationService.self) private var loc
    @State private var selectedCard: DivinationCard? = nil
    @State private var selectedSuit: CardSuit? = nil

    private let goldLight = Color(red: 1, green: 0.85, blue: 0.4)
    private let goldDark = Color(red: 0.85, green: 0.65, blue: 0.2)
    private let bgDark = Color(red: 0.06, green: 0.04, blue: 0.12)

    private var allCards: [DivinationCard] {
        DivinationCard.allCards(for: deityID)
    }

    private var filteredCards: [DivinationCard] {
        guard let suit = selectedSuit else { return allCards }
        return allCards.filter { $0.suit == suit }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                bgDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        suitFilter
                        cardsGrid
                    }
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(galleryTitle)
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

    private var galleryTitle: String {
        switch loc.currentLanguage {
        case .english: return "Card Gallery"
        case .chinese: return "卡牌图鉴"
        case .hindi: return "कार्ड गैलरी"
        }
    }

    private var headerSection: some View {
        let deity = Deity.deity(for: deityID)
        return VStack(spacing: 8) {
            Text(deity.symbol)
                .font(.system(size: 36))

            Text(deity.localizedName(for: loc.currentLanguage))
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundStyle(goldLight)

            Text(cardCountText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.top, 8)
    }

    private var cardCountText: String {
        let count = allCards.count
        switch loc.currentLanguage {
        case .english: return "\(count) Sacred Cards"
        case .chinese: return "\(count) 张神圣卡牌"
        case .hindi: return "\(count) पवित्र कार्ड"
        }
    }

    private var suitFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                suitFilterButton(suit: nil, label: allLabel)
                ForEach(CardSuit.allCases, id: \.self) { suit in
                    suitFilterButton(suit: suit, label: suit.localizedName(for: loc.currentLanguage))
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private var allLabel: String {
        switch loc.currentLanguage {
        case .english: return "All"
        case .chinese: return "全部"
        case .hindi: return "सभी"
        }
    }

    private func suitFilterButton(suit: CardSuit?, label: String) -> some View {
        let isSelected = selectedSuit == suit
        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedSuit = suit
            }
        } label: {
            HStack(spacing: 5) {
                if let suit {
                    Image(systemName: suit.sfSymbol)
                        .font(.system(size: 11))
                        .foregroundStyle(suitColor(suit))
                }
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? goldLight : .white.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? deityColor.opacity(0.25) : .white.opacity(0.05))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? goldLight.opacity(0.4) : .clear, lineWidth: 1)
                    )
            )
        }
    }

    private var cardsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ], spacing: 16) {
            ForEach(filteredCards) { card in
                galleryCardTile(card)
            }
        }
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.35), value: selectedSuit)
    }

    private func galleryCardTile(_ card: DivinationCard) -> some View {
        Button {
            selectedCard = card
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [deityColor.opacity(0.3), deityColor.opacity(0.08)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(goldDark.opacity(0.3), lineWidth: 1)
                        )

                    VStack(spacing: 4) {
                        Text(card.romanNumeral)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(goldLight.opacity(0.6))

                        if let uiImage = UIImage(named: card.imageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 65, height: 75)
                                .clipShape(.rect(cornerRadius: 8))
                        }

                        Image(systemName: card.suit.sfSymbol)
                            .font(.system(size: 10))
                            .foregroundStyle(suitColor(card.suit))
                    }
                    .padding(6)
                }
                .frame(height: 120)

                Text(card.localizedName(for: loc.currentLanguage))
                    .font(.system(size: 10, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(card.localizedMeaning(for: loc.currentLanguage))
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .buttonStyle(.plain)
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
