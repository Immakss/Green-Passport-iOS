import Foundation

struct HomeUiState {
    var isLoading = true
    var hasTasksError = false
    var displayName: String?
    var avatar: AvatarStyle = .lime
    var points = 0
    var level: Level?
    var streak: Streak?
    var upcomingEvent: EcoEvent?
    var tasks: [EcoTask] = []

    var streakDays: Int {
        return streak?.currentCount(at: Date()) ?? 0
    }
}
