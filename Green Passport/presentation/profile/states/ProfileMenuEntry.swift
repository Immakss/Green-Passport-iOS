import SwiftUI

enum ProfileMenuEntry: CaseIterable {
    case achievements
    case cards
    case history
    case notifications
    case favorites
    case bookmarks
    case exchange

    var title: LocalizedStringResource {
        switch self {
        case .achievements:
            return .profileAchievements
        case .cards:
            return .profileCards
        case .history:
            return .profileHistory
        case .notifications:
            return .notificationsScreenTitle
        case .favorites:
            return .profileFavorites
        case .bookmarks:
            return .profileBookmarks
        case .exchange:
            return .profileExchange
        }
    }

    var systemImage: String {
        switch self {
        case .achievements:
            return "trophy.fill"
        case .cards:
            return "rectangle.stack.fill"
        case .history:
            return "clock.arrow.circlepath"
        case .notifications:
            return "bell.fill"
        case .favorites:
            return "heart.fill"
        case .bookmarks:
            return "bookmark.fill"
        case .exchange:
            return "arrow.left.arrow.right"
        }
    }


    var destination: AppDestination {
        switch self {
        case .achievements:
            return .achievements
        case .cards:
            return .cards
        case .history:
            return .history
        case .notifications:
            return .notifications
        case .favorites:
            return .favorites(.tasks)
        case .bookmarks:
            return .favorites(.tips)
        case .exchange:
            return .exchange
        }
    }

    var color: Color {
        switch self {
        case .achievements:
            return SectionColor.tips
        case .cards:
            return SectionColor.games
        case .history:
            return SectionColor.calendar
        case .notifications:
            return SectionColor.feedback
        case .favorites:
            return SectionColor.feedback
        case .bookmarks:
            return SectionColor.community
        case .exchange:
            return SectionColor.games
        }
    }
}
