final class ObserveMapPointsUseCase {
    private let mapPointsRepository: MapPointsRepository

    init(mapPointsRepository: MapPointsRepository) {
        self.mapPointsRepository = mapPointsRepository
    }

    func execute() -> AsyncThrowingStream<[MapPoint], Error> {
        return StreamCombiner.mapped(mapPointsRepository.observePoints()) { points in
            return points.filter { return $0.isActive }
        }
    }
}
