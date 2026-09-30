final class FetchBestScoresUseCase {
    private let gameProgressRepository: GameProgressRepository

    init(gameProgressRepository: GameProgressRepository) {
        self.gameProgressRepository = gameProgressRepository
    }

    func execute() -> [GameId: Int] {
        let scores = gameProgressRepository.bestScores()
        return Dictionary(uniqueKeysWithValues: GameId.allCases.compactMap { id in
            return scores[id.rawValue].map { return (id, $0) }
        })
    }
}
