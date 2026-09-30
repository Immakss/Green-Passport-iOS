import Foundation

nonisolated struct HistoryEntry: Identifiable, Hashable, Sendable {
    let id: String
    let type: HistoryEntryType
    let title: String
    let timestamp: Date
}
