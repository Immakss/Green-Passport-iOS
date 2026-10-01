nonisolated enum MapFocus: Hashable, Sendable {
    case userLocation(GeoPoint)
    case city(GeoPoint)
}
