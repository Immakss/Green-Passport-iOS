import Foundation
import SwiftData

final class SwiftDataGameProgressRepository: GameProgressRepository {
    private let context: ModelContext?

    init(container: ModelContainer?) {
        context = container?.mainContext
    }

    func bestScores() -> [String: Int] {
        let records = (try? context?.fetch(FetchDescriptor<GameProgressRecord>())) ?? []
        return Dictionary(records.map { return ($0.gameId, $0.bestScore) }) { first, _ in
            return first
        }
    }

    func recordScore(gameId: String, score: Int) {
        guard let context else {
            return
        }
        let descriptor = FetchDescriptor<GameProgressRecord>(predicate: #Predicate { $0.gameId == gameId })
        if let existing = try? context.fetch(descriptor).first {
            existing.bestScore = max(existing.bestScore, score)
            existing.lastPlayedAt = Date()
        } else {
            context.insert(GameProgressRecord(gameId: gameId, bestScore: score, lastPlayedAt: Date()))
        }
        try? context.save()
    }
}
