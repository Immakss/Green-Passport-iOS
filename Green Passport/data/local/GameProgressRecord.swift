import Foundation
import SwiftData

@Model
final class GameProgressRecord {
    @Attribute(.unique) var gameId: String
    var bestScore: Int
    var lastPlayedAt: Date

    init(gameId: String, bestScore: Int, lastPlayedAt: Date) {
        self.gameId = gameId
        self.bestScore = bestScore
        self.lastPlayedAt = lastPlayedAt
    }
}
