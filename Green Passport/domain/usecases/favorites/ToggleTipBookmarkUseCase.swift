final class ToggleTipBookmarkUseCase {
    private let favoritesRepository: FavoritesRepository

    init(favoritesRepository: FavoritesRepository) {
        self.favoritesRepository = favoritesRepository
    }

    func execute(userId: String, tipId: String, isBookmarked: Bool) async throws {
        try await favoritesRepository.setTipBookmarked(userId: userId, tipId: tipId, isBookmarked: isBookmarked)
    }
}
