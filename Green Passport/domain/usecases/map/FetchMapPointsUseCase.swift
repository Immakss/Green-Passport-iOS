final class FetchMapPointsUseCase {
    private let mapPointsRepository: MapPointsRepository

    init(mapPointsRepository: MapPointsRepository) {
        self.mapPointsRepository = mapPointsRepository
    }

    func execute() async throws -> [MapPoint] {
        return try await mapPointsRepository.fetchPoints()
    }
}
