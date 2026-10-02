import Foundation

nonisolated struct StreakWeekDay: Hashable, Sendable, Identifiable {
    let date: Date
    let isActive: Bool
    let isToday: Bool

    var id: Date {
        return date
    }
}
