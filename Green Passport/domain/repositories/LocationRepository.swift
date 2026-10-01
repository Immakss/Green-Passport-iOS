protocol LocationRepository {
    func currentLocation() async -> GeoPoint?
}
