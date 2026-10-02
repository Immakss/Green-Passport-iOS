import SwiftUI

enum ProfileMenuEntry: CaseIterable {
    case achievements
    case coupons
    case history
    case notifications

    var title: LocalizedStringResource {
        switch self {
        case .achievements:
            return .profileAchievements
        case .coupons:
            return .myCoupons
        case .history:
            return .profileHistory
        case .notifications:
            return .notificationsScreenTitle
        }
    }

    var systemImage: String {
        switch self {
        case .achievements:
            return "trophy.fill"
        case .coupons:
            return "ticket.fill"
        case .history:
            return "clock.arrow.circlepath"
        case .notifications:
            return "bell.fill"
        }
    }

    var destination: AppDestination {
        switch self {
        case .achievements:
            return .achievements
        case .coupons:
            return .coupons
        case .history:
            return .history
        case .notifications:
            return .notifications
        }
    }

    var color: Color {
        switch self {
        case .achievements:
            return SectionColor.tips
        case .coupons:
            return SectionColor.community
        case .history:
            return SectionColor.calendar
        case .notifications:
            return SectionColor.feedback
        }
    }
}
