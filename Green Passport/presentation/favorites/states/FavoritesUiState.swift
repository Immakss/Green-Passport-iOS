struct FavoritesUiState {
    var tasks: [EcoTask] = []
    var tips: [EcoTip] = []
    var mapPoints: [MapPoint] = []
    var favoriteTaskIds: Set<String> = []
    var bookmarkedTipIds: Set<String> = []
    var savedMapPointIds: Set<String> = []
    var isLoading = true
    var hasError = false

    var favoriteTasks: [EcoTask] {
        return tasks.filter { return favoriteTaskIds.contains($0.id) }
    }

    var bookmarkedTips: [EcoTip] {
        return tips.filter { return bookmarkedTipIds.contains($0.id) }
    }

    var savedPlaces: [MapPoint] {
        return mapPoints.filter { return savedMapPointIds.contains($0.id) }
    }
}
