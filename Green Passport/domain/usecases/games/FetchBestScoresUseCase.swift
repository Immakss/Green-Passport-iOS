final class FetchBestScoresUseCase {
    private let gameProgressRepository: GameProgressRepository

    init(gameProgressRepository: GameProgressRepository) {
        self.gameProgressRepository = gameProgressRepository
    }

    func execute() -> [String: Int] {
        return gameProgressRepository.bestScores()
    }
}
