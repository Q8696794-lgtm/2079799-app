import SwiftUI

struct CardDetailSheet: View {
    let drawn: DrawnCard
    let language: AppLanguage
    let deityColor: Color

    private let goldLight = Color(red: 1, green: 0.85, blue: 0.4)
    private let goldDark = Color(red: 0.85, green: 0.65, blue: 0.2)
    private let bgDark = Color(red: 0.06, green: 0.04, blue: 0.12)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                cardImageSection
                cardInfoSection
                positionSection
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
                            colors: [deityColor.opacity(0.4), deityColor.opacity(0.1)],
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
                    Text(drawn.card.romanNumeral)
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundStyle(goldLight.opacity(0.7))

                    if let uiImage = UIImage(named: drawn.card.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 260)
                            .clipShape(.rect(cornerRadius: 12))
                            .shadow(color: deityColor.opacity(0.5), radius: 12)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: drawn.card.suit.sfSymbol)
                            .font(.system(size: 12))
                            .foregroundStyle(suitColor)
                        Text(drawn.card.suit.localizedName(for: language))
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
            Text(drawn.card.localizedName(for: language))
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(goldLight)
                .multilineTextAlignment(.center)

            if language != .english {
                Text(drawn.card.nameEN)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text(drawn.card.localizedMeaning(for: language))
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 2)
        }
    }

    private var positionSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .foregroundStyle(goldLight)
                Text(drawn.position.localizedName(for: language))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(goldLight)
            }

            Text(drawn.position.localizedMeaning(for: language))
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(goldDark.opacity(0.15), lineWidth: 0.5)
                )
        )
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

            Text(drawn.card.localizedDescription(for: language))
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(6)

            Divider().overlay(goldDark.opacity(0.2))

            HStack(spacing: 8) {
                Image(systemName: drawn.card.suit.sfSymbol)
                    .foregroundStyle(suitColor)
                Text(drawn.card.suit.localizedMeaning(for: language))
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
        switch drawn.card.suit {
        case .dharma: return .orange
        case .karma: return .red
        case .kama: return .pink
        case .moksha: return .cyan
        }
    }
}
