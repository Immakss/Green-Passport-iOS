protocol MapPointsRepository {
    func observePoints() -> AsyncThrowingStream<[MapPoint], Error>
}
