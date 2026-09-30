import Foundation

protocol GamesRepository {
    func fetchGames() async throws -> [Game]
    func url(for game: Game, language: String, theme: String) -> URL?
}
