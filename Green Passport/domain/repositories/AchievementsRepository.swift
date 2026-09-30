protocol AchievementsRepository {
    func fetchAchievements(userId: String) async throws -> [Achievement]
}
