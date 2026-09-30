import SwiftUI

enum ProfileMenuEntry: CaseIterable {
    case achievements
    case cards
    case history
    case exchange

    var title: LocalizedStringResource {
        switch self {
        case .achievements:
            return .profileAchievements
        case .cards:
            return .profileCards
        case .history:
            return .profileHistory
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
        case .exchange:
            return "arrow.left.arrow.right"
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
        case .exchange:
            return SectionColor.games
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
        case .exchange:
            return .exchange
        }
    }
}
