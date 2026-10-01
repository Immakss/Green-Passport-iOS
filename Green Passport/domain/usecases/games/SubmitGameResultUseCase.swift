final class SubmitGameResultUseCase {
    private let gameProgressRepository: GameProgressRepository
    private let rewardsRepository: RewardsRepository
    private let authRepository: AuthRepository

    init(gameProgressRepository: GameProgressRepository, rewardsRepository: RewardsRepository, authRepository: AuthRepository) {
        self.gameProgressRepository = gameProgressRepository
        self.rewardsRepository = rewardsRepository
        self.authRepository = authRepository
    }

    func execute(gameId: String, score: Int) async throws -> RewardResult? {
        gameProgressRepository.recordScore(gameId: gameId, score: score)
        guard score > 0, await isSignedIn() else {
            return nil
        }
        return try await rewardsRepository.recordGameResult(gameId: gameId, score: score)
    }

    private func isSignedIn() async -> Bool {
        for await session in authRepository.observeSession() {
            return session != nil
        }
        return false
    }
}
