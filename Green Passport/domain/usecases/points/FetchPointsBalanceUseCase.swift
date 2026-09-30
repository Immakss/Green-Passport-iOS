final class FetchPointsBalanceUseCase {
    private let pointsRepository: PointsRepository

    init(pointsRepository: PointsRepository) {
        self.pointsRepository = pointsRepository
    }

    func execute(userId: String) async throws -> Int {
        return try await pointsRepository.fetchAvailablePoints(userId: userId)
    }
}
