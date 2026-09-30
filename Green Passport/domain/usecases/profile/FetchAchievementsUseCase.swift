final class FetchAchievementsUseCase {
    private let achievementsRepository: AchievementsRepository

    init(achievementsRepository: AchievementsRepository) {
        self.achievementsRepository = achievementsRepository
    }

    func execute(userId: String) async throws -> [Achievement] {
        return try await achievementsRepository.fetchAchievements(userId: userId)
    }
}
