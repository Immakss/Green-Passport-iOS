final class ToggleTaskFavoriteUseCase {
    private let favoritesRepository: FavoritesRepository

    init(favoritesRepository: FavoritesRepository) {
        self.favoritesRepository = favoritesRepository
    }

    func execute(userId: String, taskId: String, isFavorite: Bool) async throws {
        try await favoritesRepository.setTaskFavorite(userId: userId, taskId: taskId, isFavorite: isFavorite)
    }
}
