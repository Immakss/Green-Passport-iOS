import Foundation

nonisolated struct NotificationLogEntry: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let body: String
    let sentAt: Date
}
