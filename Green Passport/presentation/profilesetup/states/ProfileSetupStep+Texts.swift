import Foundation

extension ProfileSetupStep {
    var title: LocalizedStringResource {
        switch self {
        case .name:
            return .whatIsYourName
        case .city:
            return .yourCity
        case .interests:
            return .whatInterestsYou
        case .avatar:
            return .chooseAvatar
        }
    }

    var subtitle: LocalizedStringResource {
        switch self {
        case .name:
            return .nameShownToCommunityMsg
        case .city:
            return .weShowTasksAndEventsNearbyMsg
        case .interests:
            return .chooseOneOrMoreMsg
        case .avatar:
            return .avatarCanBeChangedLaterMsg
        }
    }
}
