struct ProfileUiState {
    var email: String?
    var isAnonymous = false
    var profile: UserProfile?
    var isModerator = false
    var notificationsEnabled = true
    var theme: AppTheme = .system
    var level: Level?
    var points = 0
    var isLoading = true
    var hasError = false
}
