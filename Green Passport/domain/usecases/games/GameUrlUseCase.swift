import Foundation

final class GameUrlUseCase {
    private let gamesRepository: GamesRepository

    init(gamesRepository: GamesRepository) {
        self.gamesRepository = gamesRepository
    }

    func execute(game: Game, language: String, isDark: Bool) -> URL? {
        return gamesRepository.url(for: game, language: language, theme: isDark ? "dark" : "light")
    }
}
