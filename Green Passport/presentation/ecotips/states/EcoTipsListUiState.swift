struct EcoTipsListUiState {
    var tips: [EcoTip] = []
    var readTipIds: Set<String> = []
    var bookmarkedTipIds: Set<String> = []
    var filter: EcoTipFilter = .all
    var isLoading = true
    var hasError = false

    var dailyTip: EcoTip? {
        return tips.first { $0.isDailyTip }
    }

    var visibleTips: [EcoTip] {
        switch filter {
        case .all:
            return tips
        case .category(let category):
            return tips.filter { $0.category == category }
        }
    }
}
