enum ProfileUserAction {
    case open(AppDestination)
    case editProfile
    case moderation
    case language
    case notificationsToggled(Bool)
    case signOut
    case retry
}
