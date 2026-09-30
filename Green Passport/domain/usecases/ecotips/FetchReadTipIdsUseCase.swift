final class FetchReadTipIdsUseCase {
    private let ecoTipsRepository: EcoTipsRepository

    init(ecoTipsRepository: EcoTipsRepository) {
        self.ecoTipsRepository = ecoTipsRepository
    }

    func execute(userId: String) async throws -> Set<String> {
        return try await ecoTipsRepository.fetchReadTipIds(userId: userId)
    }
}
