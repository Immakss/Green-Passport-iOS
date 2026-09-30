import SwiftUI

struct AppDestinationView: View {
    let destination: AppDestination
    let container: AppDIContainer

    var body: some View {
        switch destination {
        case .tasks:
            TasksListRoute(container: container)
        case .profile:
            ProfileRoute(container: container)
        case .achievements:
            AchievementsRoute(container: container)
        case .cards:
            CardsRoute(container: container)
        case .history:
            HistoryRoute(container: container)
        case .exchange:
            ExchangeScreen()
        case .calendar:
            CalendarRoute(container: container)
        case .favorites(let segment):
            FavoritesRoute(container: container, initialSegment: segment)
        case .community, .games, .ecoTips, .feedback, .ecoTipDetail:
            StateView(kind: .loading)
        }
    }
}
