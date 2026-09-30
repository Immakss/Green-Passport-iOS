import Observation

@Observable
final class WasteSortingViewModel {
    private static let gameDurationSeconds = 30
    private static let pointsPerCorrectAnswer = 10
    private static let tickInterval = Duration.seconds(1)

    @ObservationIgnored private let gameSession: GameSession
    @ObservationIgnored private let timer = LatestTask()

    private(set) var uiState = WasteSortingUiState(
        currentItem: WasteItem.pool.randomElement(),
        secondsRemaining: WasteSortingViewModel.gameDurationSeconds
    )

    init(gameSession: GameSession) {
        self.gameSession = gameSession
    }

    func start() {
        timer.run { [weak self] in
            await self?.runTimer()
        }
    }

    func stop() {
        timer.cancel()
    }

    func select(_ category: WasteCategory) {
        guard !uiState.isFinished, let current = uiState.currentItem else {
            return
        }
        let isCorrect = current.category == category
        if isCorrect {
            uiState.score += Self.pointsPerCorrectAnswer
        }
        uiState.lastAnswerCorrect = isCorrect
        uiState.answerCount += 1
        uiState.currentItem = WasteItem.pool.randomElement()
    }

    func restart() {
        uiState = WasteSortingUiState(currentItem: WasteItem.pool.randomElement(), secondsRemaining: Self.gameDurationSeconds)
        start()
    }

    private func runTimer() async {
        while uiState.secondsRemaining > 0 {
            do {
                try await Task.sleep(for: Self.tickInterval)
            } catch {
                return
            }
            uiState.secondsRemaining -= 1
        }
        uiState.isFinished = true
        uiState.currentItem = nil
        gameSession.submit(gameId: .wasteSorting, score: uiState.score)
    }
}
