import Foundation

nonisolated struct StreakSummary: Hashable, Sendable {
    let days: Int
    let isTodayCounted: Bool
    let daysUntilBonus: Int
    let week: [StreakWeekDay]
}
