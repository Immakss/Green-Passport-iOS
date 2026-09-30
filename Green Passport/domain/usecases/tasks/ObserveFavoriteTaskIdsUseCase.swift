final class ObserveFavoriteTaskIdsUseCase {
    private let favoritesRepository: FavoritesRepository

    init(favoritesRepository: FavoritesRepository) {
        self.favoritesRepository = favoritesRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        return favoritesRepository.observeFavoriteTaskIds(userId: userId)
    }
}
