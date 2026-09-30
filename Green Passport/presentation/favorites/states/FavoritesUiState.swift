struct FavoritesUiState {
    var tasks: [EcoTask] = []
    var tips: [EcoTip] = []
    var favoriteTaskIds: Set<String> = []
    var bookmarkedTipIds: Set<String> = []
    var isLoading = true
    var hasError = false

    var favoriteTasks: [EcoTask] {
        return tasks.filter { favoriteTaskIds.contains($0.id) }
    }

    var bookmarkedTips: [EcoTip] {
        return tips.filter { bookmarkedTipIds.contains($0.id) }
    }
}
