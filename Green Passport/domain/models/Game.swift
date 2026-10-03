import Foundation

nonisolated struct Game: Identifiable, Hashable, Sendable {
    let id: String
    let titles: [String: String]
    let path: String
    let sfSymbol: String
    var iconUrl: URL?
    var iconEmoji: String?
    var iconColors: [String] = []
    let maxPoints: Int
    let order: Int
}
