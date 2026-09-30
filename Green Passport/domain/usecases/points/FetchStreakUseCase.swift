import Foundation

final class FetchStreakUseCase {
    private let pointsRepository: PointsRepository

    init(pointsRepository: PointsRepository) {
        self.pointsRepository = pointsRepository
    }

    func execute(userId: String) async throws -> Int {
        return try await pointsRepository.fetchStreak(userId: userId)?.currentCount(at: Date()) ?? 0
    }
}
