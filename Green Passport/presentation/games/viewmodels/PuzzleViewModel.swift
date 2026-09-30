import Observation

@Observable
final class PuzzleViewModel {
    static let symbols = ["leaf.fill", "arrow.3.trianglepath", "drop.fill", "tree.fill", "camera.macro", "sun.max.fill"]
    private static let optimalMoves = symbols.count
    private static let baseScore = 100
    private static let penaltyPerExtraMove = 5
    private static let minimumScore = 10
    private static let mismatchDelay = Duration.milliseconds(800)

    @ObservationIgnored private let gameSession: GameSession
    @ObservationIgnored private var pendingFirstCardId: Int?

    private(set) var uiState = PuzzleUiState(cards: PuzzleViewModel.shuffledDeck())

    init(gameSession: GameSession) {
        self.gameSession = gameSession
    }

    func flip(_ card: PuzzleCard) {
        guard !uiState.isInputLocked, !card.isFaceUp, !card.isMatched,
              let index = uiState.cards.firstIndex(where: { return $0.id == card.id }) else {
            return
        }
        uiState.cards[index].isFaceUp = true
        guard let firstId = pendingFirstCardId,
              let firstIndex = uiState.cards.firstIndex(where: { return $0.id == firstId }) else {
            pendingFirstCardId = card.id
            return
        }
        pendingFirstCardId = nil
        uiState.moves += 1
        uiState.isInputLocked = true
        let isMatch = uiState.cards[firstIndex].symbolIndex == card.symbolIndex
        Task {
            if !isMatch {
                try? await Task.sleep(for: Self.mismatchDelay)
            }
            uiState.cards[firstIndex].isMatched = isMatch
            uiState.cards[index].isMatched = isMatch
            uiState.cards[firstIndex].isFaceUp = isMatch
            uiState.cards[index].isFaceUp = isMatch
            uiState.isInputLocked = false
            finishIfNeeded()
        }
    }

    func restart() {
        pendingFirstCardId = nil
        uiState = PuzzleUiState(cards: Self.shuffledDeck())
    }

    private func finishIfNeeded() {
        guard !uiState.isFinished, uiState.cards.allSatisfy(\.isMatched) else {
            return
        }
        let extraMoves = max(0, uiState.moves - Self.optimalMoves)
        let score = max(Self.minimumScore, Self.baseScore - extraMoves * Self.penaltyPerExtraMove)
        uiState.score = score
        uiState.isFinished = true
        gameSession.submit(gameId: .ecoPuzzle, score: score)
    }

    private static func shuffledDeck() -> [PuzzleCard] {
        let indices = symbols.indices.flatMap { return [$0, $0] }.shuffled()
        return indices.enumerated().map { offset, symbolIndex in
            return PuzzleCard(id: offset, symbolIndex: symbolIndex)
        }
    }
}
