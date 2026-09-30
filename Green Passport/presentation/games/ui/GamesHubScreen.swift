import SwiftUI

struct GamesHubScreen: View {
    private static let tileSize: CGFloat = 44

    let bestScores: [GameId: Int]
    let onGame: (GameId) -> Void

    var body: some View {
        List(GameId.allCases, id: \.self) { game in
            Button {
                onGame(game)
            } label: {
                ListRow(title: String(localized: game.title)) {
                    SymbolTile(systemImage: game.systemImage, color: game.color, size: Self.tileSize)
                } trailing: {
                    if let best = bestScores[game] {
                        Text(.gamesBestScoreFormat(best))
                            .font(.subheadline)
                            .foregroundStyle(Palette.secondaryText)
                    }
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
            .buttonStyle(.plain)
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text(.games))
    }
}

#Preview {
    NavigationStack {
        GamesHubScreen(bestScores: [.ecoQuiz: 80], onGame: { _ in })
    }
}
