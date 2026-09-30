final class ObserveBookmarkedTipIdsUseCase {
    private let favoritesRepository: FavoritesRepository

    init(favoritesRepository: FavoritesRepository) {
        self.favoritesRepository = favoritesRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        return favoritesRepository.observeBookmarkedTipIds(userId: userId)
    }
}
