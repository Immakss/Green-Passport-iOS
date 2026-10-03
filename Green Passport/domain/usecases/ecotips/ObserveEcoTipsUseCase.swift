final class ObserveEcoTipsUseCase {
    private let ecoTipsRepository: EcoTipsRepository
    private let includesArchived: Bool

    init(ecoTipsRepository: EcoTipsRepository, includesArchived: Bool = false) {
        self.ecoTipsRepository = ecoTipsRepository
        self.includesArchived = includesArchived
    }

    func execute() -> AsyncThrowingStream<[EcoTip], Error> {
        let includesArchived = includesArchived
        return StreamCombiner.mapped(ecoTipsRepository.observeTips()) { tips in
            return includesArchived ? tips : tips.filter { return $0.isActive }
        }
    }
}
