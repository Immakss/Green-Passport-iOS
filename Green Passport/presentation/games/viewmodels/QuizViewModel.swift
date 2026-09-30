import Observation

@Observable
final class QuizViewModel {
    private static let pointsPerCorrectAnswer = 20
    private static let answerFeedbackDelay = Duration.milliseconds(600)

    @ObservationIgnored private let gameSession: GameSession

    private(set) var uiState = QuizUiState()

    init(gameSession: GameSession) {
        self.gameSession = gameSession
    }

    func select(optionIndex: Int) {
        guard !uiState.isFinished, uiState.selectedOptionIndex == nil else {
            return
        }
        if optionIndex == uiState.currentQuestion.correctOptionIndex {
            uiState.correctAnswers += 1
        }
        uiState.selectedOptionIndex = optionIndex
        uiState.score = uiState.correctAnswers * Self.pointsPerCorrectAnswer
        Task {
            try? await Task.sleep(for: Self.answerFeedbackDelay)
            advance()
        }
    }

    func restart() {
        uiState = QuizUiState()
    }

    private func advance() {
        let nextIndex = uiState.currentQuestionIndex + 1
        uiState.selectedOptionIndex = nil
        guard nextIndex < QuizQuestion.all.count else {
            uiState.isFinished = true
            gameSession.submit(gameId: .ecoQuiz, score: uiState.score)
            return
        }
        uiState.currentQuestionIndex = nextIndex
    }
}
