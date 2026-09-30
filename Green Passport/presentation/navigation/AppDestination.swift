enum AppDestination: Hashable {
    case tasks
    case profile
    case achievements
    case cards
    case history
    case exchange
    case community
    case games
    case ecoTips
    case calendar
    case feedback
    case favorites(FavoritesSegment)
    case ecoTipDetail(tipId: String)
    case forum
    case groups
}
