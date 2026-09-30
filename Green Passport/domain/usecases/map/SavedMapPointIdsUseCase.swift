final class SavedMapPointIdsUseCase {
    private let savedMapPointsRepository: SavedMapPointsRepository

    init(savedMapPointsRepository: SavedMapPointsRepository) {
        self.savedMapPointsRepository = savedMapPointsRepository
    }

    func execute() -> Set<String> {
        return savedMapPointsRepository.savedPointIds
    }
}
