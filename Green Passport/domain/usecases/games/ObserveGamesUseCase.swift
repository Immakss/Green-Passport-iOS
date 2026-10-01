final class ObserveGamesUseCase {
    private let gamesRepository: GamesRepository

    init(gamesRepository: GamesRepository) {
        self.gamesRepository = gamesRepository
    }

    func execute() -> AsyncThrowingStream<[Game], Error> {
        return gamesRepository.observeGames()
    }
}
