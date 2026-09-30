final class FetchGamesUseCase {
    private let gamesRepository: GamesRepository

    init(gamesRepository: GamesRepository) {
        self.gamesRepository = gamesRepository
    }

    func execute() async throws -> [Game] {
        return try await gamesRepository.fetchGames()
    }
}
