import SwiftUI

enum HomeQuickAction: CaseIterable {
    case community
    case games
    case ecoTips
    case calendar
    case feedback

    var destination: AppDestination {
        switch self {
        case .community:
            return .community
        case .games:
            return .games
        case .ecoTips:
            return .ecoTips
        case .calendar:
            return .calendar
        case .feedback:
            return .feedback
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .community:
            return .community
        case .games:
            return .games
        case .ecoTips:
            return .tips
        case .calendar:
            return .calendar
        case .feedback:
            return .feedback
        }
    }

    var systemImage: String {
        switch self {
        case .community:
            return "person.3.fill"
        case .games:
            return "gamecontroller.fill"
        case .ecoTips:
            return "leaf.fill"
        case .calendar:
            return "calendar"
        case .feedback:
            return "text.bubble.fill"
        }
    }

    var color: Color {
        switch self {
        case .community:
            return SectionColor.community
        case .games:
            return SectionColor.games
        case .ecoTips:
            return SectionColor.tips
        case .calendar:
            return SectionColor.calendar
        case .feedback:
            return SectionColor.feedback
        }
    }
}
