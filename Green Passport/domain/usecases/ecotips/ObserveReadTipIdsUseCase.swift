final class ObserveReadTipIdsUseCase {
    private let ecoTipsRepository: EcoTipsRepository

    init(ecoTipsRepository: EcoTipsRepository) {
        self.ecoTipsRepository = ecoTipsRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        return ecoTipsRepository.observeReadTipIds(userId: userId)
    }
}
