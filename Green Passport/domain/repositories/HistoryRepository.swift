protocol HistoryRepository {
    func fetchHistory(userId: String) async throws -> [HistoryEntry]
}
