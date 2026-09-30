protocol FavoritesRepository {
    func observeFavoriteTaskIds(userId: String) -> AsyncThrowingStream<Set<String>, Error>
    func setTaskFavorite(userId: String, taskId: String, isFavorite: Bool) async throws
    func observeBookmarkedTipIds(userId: String) -> AsyncThrowingStream<Set<String>, Error>
    func setTipBookmarked(userId: String, tipId: String, isBookmarked: Bool) async throws
}
