protocol PointsRepository {
    func fetchAvailablePoints(userId: String) async throws -> Int
    func fetchLifetimeXp(userId: String) async throws -> Int
}
