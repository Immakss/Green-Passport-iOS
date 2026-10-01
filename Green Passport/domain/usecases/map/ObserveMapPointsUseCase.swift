final class ObserveMapPointsUseCase {
    private let mapPointsRepository: MapPointsRepository

    init(mapPointsRepository: MapPointsRepository) {
        self.mapPointsRepository = mapPointsRepository
    }

    func execute() -> AsyncThrowingStream<[MapPoint], Error> {
        return mapPointsRepository.observePoints()
    }
}
