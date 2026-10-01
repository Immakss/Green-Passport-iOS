final class ObserveEcoTipsUseCase {
    private let ecoTipsRepository: EcoTipsRepository

    init(ecoTipsRepository: EcoTipsRepository) {
        self.ecoTipsRepository = ecoTipsRepository
    }

    func execute() -> AsyncThrowingStream<[EcoTip], Error> {
        return ecoTipsRepository.observeTips()
    }
}
