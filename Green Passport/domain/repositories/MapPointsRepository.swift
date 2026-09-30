protocol MapPointsRepository {
    func fetchPoints() async throws -> [MapPoint]
}
