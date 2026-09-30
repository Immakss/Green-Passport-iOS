final class FetchLevelUseCase {
    private let pointsRepository: PointsRepository

    init(pointsRepository: PointsRepository) {
        self.pointsRepository = pointsRepository
    }

    func execute(userId: String) async throws -> Level {
        return Level(lifetimeXp: try await pointsRepository.fetchLifetimeXp(userId: userId))
    }
}
