struct HomeUiState {
    var isLoading = true
    var hasTasksError = false
    var displayName: String?
    var avatar: AvatarStyle = .lime
    var points = 0
    var level: Level?
    var upcomingEvent: EcoEvent?
    var tasks: [EcoTask] = []
}
