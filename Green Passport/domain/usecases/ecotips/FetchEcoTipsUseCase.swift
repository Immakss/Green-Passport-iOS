final class FetchEcoTipsUseCase {
    private let ecoTipsRepository: EcoTipsRepository

    init(ecoTipsRepository: EcoTipsRepository) {
        self.ecoTipsRepository = ecoTipsRepository
    }

    func execute() async throws -> [EcoTip] {
        return try await ecoTipsRepository.fetchTips()
    }
}
