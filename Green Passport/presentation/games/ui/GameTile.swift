import SwiftUI

struct GameTile: View {
    private static let emojiScale: CGFloat = 0.46
    private static let breathScale: CGFloat = 1.06
    private static let breathDuration: Double = 1.8
    private static let titleLineLimit = 2

    let game: Game
    let bestScore: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            artwork
            Text(game.title)
                .font(.headline)
                .foregroundStyle(Color.primary)
                .lineLimit(Self.titleLineLimit, reservesSpace: true)
            if let bestScore {
                Text(.gamesBestScoreFormat(bestScore))
                    .font(.footnote)
                    .foregroundStyle(Palette.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    private var artwork: some View {
        return RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
            .fill(LinearGradient(colors: game.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                AsyncImage(url: game.iconUrl) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        emojiFallback
                    }
                }
            }
            .clipShape(.rect(cornerRadius: CornerRadius.large, style: .continuous))
            .accessibilityHidden(true)
    }

    private var emojiFallback: some View {
        return GeometryReader { proxy in
            Text(game.tileEmoji)
                .font(.system(size: proxy.size.width * Self.emojiScale))
                .phaseAnimator([1, Self.breathScale]) { content, scale in
                    content.scaleEffect(scale)
                } animation: { _ in
                    return .easeInOut(duration: Self.breathDuration)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

#Preview {
    GameTile(
        game: Game(id: "bee_garden", titles: ["ru": "Опылитель"], path: "bee_garden/index.html", sfSymbol: "leaf.fill", iconEmoji: "🐝", iconColors: ["#FFB703", "#FB8500"], maxPoints: 30, order: 1),
        bestScore: 12
    )
    .frame(width: 170)
    .padding()
}
