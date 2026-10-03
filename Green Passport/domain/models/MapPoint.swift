nonisolated struct MapPoint: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let type: MapPointType
    let address: String
    let city: String
    let latitude: Double
    let longitude: Double
    var isActive = true
}
