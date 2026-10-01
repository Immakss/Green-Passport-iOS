import Foundation

protocol GamesRepository {
    func observeGames() -> AsyncThrowingStream<[Game], Error>
    func url(for game: Game, language: String, theme: String) -> URL?
}
