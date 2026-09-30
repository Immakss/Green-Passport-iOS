import SwiftUI

struct PuzzleScreen: View {
    private static let columnCount = 4
    private static let symbolSize: CGFloat = 28
    private static let flippedAngle: Double = 180
    private static let hiddenSymbolOpacity: Double = 0.5
    private static let matchedOpacity: Double = 0.6
    private static let flipDuration: Double = 0.35

    let uiState: PuzzleUiState
    let onFlip: (PuzzleCard) -> Void
    let onRestart: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                if uiState.isFinished {
                    GameResultView(
                        message: String(localized: .puzzleFinishedFormat(uiState.moves, uiState.score)),
                        onPlayAgain: onRestart
                    )
                } else {
                    Text(.puzzleInstructions)
                        .font(.subheadline)
                        .foregroundStyle(Palette.secondaryText)
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.small), count: Self.columnCount),
                        spacing: Spacing.small
                    ) {
                        ForEach(uiState.cards) { card in
                            cardView(card)
                        }
                    }
                }
            }
            .padding(Spacing.screenHorizontal)
            .animation(.snappy, value: uiState.isFinished)
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.gameEcoPuzzleTitle))
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: uiState.cards.filter(\.isMatched).count)
    }

    private func cardView(_ card: PuzzleCard) -> some View {
        let isRevealed = card.isFaceUp || card.isMatched
        return Button {
            onFlip(card)
        } label: {
            RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous)
                .fill(isRevealed ? AnyShapeStyle(Palette.mintSurface) : AnyShapeStyle(Palette.forest.gradient))
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Image(systemName: isRevealed ? PuzzleViewModel.symbols[card.symbolIndex] : "leaf")
                        .font(.system(size: Self.symbolSize, weight: .semibold))
                        .foregroundStyle(isRevealed ? Palette.forest : Palette.onForest.opacity(Self.hiddenSymbolOpacity))
                        .scaleEffect(x: isRevealed ? -1 : 1)
                }
                .rotation3DEffect(.degrees(isRevealed ? Self.flippedAngle : 0), axis: (x: 0, y: 1, z: 0))
                .opacity(card.isMatched ? Self.matchedOpacity : 1)
                .animation(.spring(duration: Self.flipDuration), value: isRevealed)
        }
        .buttonStyle(.plain)
        .disabled(uiState.isInputLocked || isRevealed)
    }
}

#Preview {
    NavigationStack {
        PuzzleScreen(uiState: PuzzleUiState(cards: (0..<12).map { return PuzzleCard(id: $0, symbolIndex: $0 / 2, isFaceUp: $0 < 2) }), onFlip: { _ in }, onRestart: {})
    }
}
