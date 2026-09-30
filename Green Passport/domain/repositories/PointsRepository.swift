protocol PointsRepository {
    func fetchAvailablePoints(userId: String) async throws -> Int
    func fetchLifetimeXp(userId: String) async throws -> Int
    func fetchStreak(userId: String) async throws -> Streak?
}
