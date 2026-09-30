final class GameSession {
    private let observeSession: ObserveSessionUseCase
    private let submitGameResult: SubmitGameResultUseCase

    init(observeSession: ObserveSessionUseCase, submitGameResult: SubmitGameResultUseCase) {
        self.observeSession = observeSession
        self.submitGameResult = submitGameResult
    }

    func submit(gameId: GameId, score: Int) {
        Task {
            let isSignedIn = await observeSession.current() != nil
            await submitGameResult.execute(gameId: gameId, score: score, isSignedIn: isSignedIn)
        }
    }
}
