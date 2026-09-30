protocol SavedMapPointsRepository {
    var savedPointIds: Set<String> { get }
    func setSaved(pointId: String, isSaved: Bool)
}
