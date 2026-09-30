final class SubmitGameResultUseCase {
    private let gameProgressRepository: GameProgressRepository
    private let rewardsRepository: RewardsRepository

    init(gameProgressRepository: GameProgressRepository, rewardsRepository: RewardsRepository) {
        self.gameProgressRepository = gameProgressRepository
        self.rewardsRepository = rewardsRepository
    }

    func execute(gameId: GameId, score: Int, isSignedIn: Bool) async {
        gameProgressRepository.recordScore(gameId: gameId.rawValue, score: score)
        guard isSignedIn else {
            return
        }
        _ = try? await rewardsRepository.recordGameResult(gameId: gameId.rawValue, score: score)
    }
}
