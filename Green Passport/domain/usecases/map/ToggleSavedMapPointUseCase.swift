final class ToggleSavedMapPointUseCase {
    private let savedMapPointsRepository: SavedMapPointsRepository

    init(savedMapPointsRepository: SavedMapPointsRepository) {
        self.savedMapPointsRepository = savedMapPointsRepository
    }

    func execute(pointId: String, isSaved: Bool) {
        savedMapPointsRepository.setSaved(pointId: pointId, isSaved: isSaved)
    }
}
