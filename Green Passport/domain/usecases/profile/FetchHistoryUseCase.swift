final class FetchHistoryUseCase {
    private let historyRepository: HistoryRepository

    init(historyRepository: HistoryRepository) {
        self.historyRepository = historyRepository
    }

    func execute(userId: String) async throws -> [HistoryEntry] {
        return try await historyRepository.fetchHistory(userId: userId)
    }
}
