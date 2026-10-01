import FirebaseFirestore
import Foundation

final class FirestoreGamesRepository: GamesRepository {
    private static let fieldTitles = "titles"
    private static let fieldPath = "path"
    private static let fieldSfSymbol = "sfSymbol"
    private static let fieldMaxPoints = "maxPoints"
    private static let fieldOrder = "order"
    private static let fieldIsActive = "isActive"
    private static let baseUrlInfoKey = "GamesBaseURL"
    private static let languageParameter = "lang"
    private static let themeParameter = "theme"
    private static let defaultSymbol = "gamecontroller.fill"
    private static let defaultMaxPoints = 30

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeGames() -> AsyncThrowingStream<[Game], Error> {
        let query = FirestoreCollections.games(firestore).whereField(Self.fieldIsActive, isEqualTo: true)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return snapshot.documents
                .compactMap { document -> Game? in
                    guard let path = document.string(Self.fieldPath) else {
                        return nil
                    }
                    return Game(
                        id: document.documentID,
                        titles: document.get(Self.fieldTitles) as? [String: String] ?? [:],
                        path: path,
                        sfSymbol: document.string(Self.fieldSfSymbol) ?? Self.defaultSymbol,
                        maxPoints: document.int(Self.fieldMaxPoints) ?? Self.defaultMaxPoints,
                        order: document.int(Self.fieldOrder) ?? Int.max
                    )
                }
                .sorted { return $0.order < $1.order }
        }
    }

    func url(for game: Game, language: String, theme: String) -> URL? {
        guard let base = Bundle.main.object(forInfoDictionaryKey: Self.baseUrlInfoKey) as? String,
              let baseUrl = URL(string: base) else {
            return nil
        }
        var components = URLComponents(url: baseUrl.appending(path: game.path), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: Self.languageParameter, value: language),
            URLQueryItem(name: Self.themeParameter, value: theme),
        ]
        return components?.url
    }
}
