import SwiftUI

struct GamesHubScreen: View {
    private static let tileSize: CGFloat = 44

    let uiState: ListUiState<Game>
    let bestScores: [String: Int]
    let onGame: (Game) -> Void
    let onRetry: () -> Void

    var body: some View {
        Group {
            switch uiState {
            case .loading:
                StateView(kind: .loading)
            case .error:
                StateView(kind: .error(retry: onRetry))
            case .success(let games):
                ScrollView {
                    VStack(spacing: Spacing.small) {
                        ForEach(games) { game in
                            row(game)
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.vertical, Spacing.xSmall)
                }
            }
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.games))
    }

    private func row(_ game: Game) -> some View {
        return Button {
            onGame(game)
        } label: {
            ListRow(title: game.title, subtitle: bestScores[game.id].map { return String(localized: .gamesBestScoreFormat($0)) }) {
                SymbolTile(systemImage: game.sfSymbol, size: Self.tileSize)
            } trailing: {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.xSmall)
            .background(Palette.cardBackground, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        GamesHubScreen(
            uiState: .success(data: [Game(id: "eco_quiz", titles: ["ru": "Эко-викторина"], path: "eco_quiz/index.html", sfSymbol: "questionmark.bubble.fill", maxPoints: 30, order: 1)]),
            bestScores: ["eco_quiz": 80],
            onGame: { _ in },
            onRetry: {}
        )
    }
}
