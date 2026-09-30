import Foundation

extension AchievementId {
    var title: LocalizedStringResource {
        switch self {
        case .firstTask:
            return .achievementFirstTaskTitle
        case .taskMaster:
            return .achievementTaskMasterTitle
        case .eventGoer:
            return .achievementEventGoerTitle
        case .ecoReader:
            return .achievementEcoReaderTitle
        case .communityMember:
            return .achievementCommunityMemberTitle
        case .levelFive:
            return .achievementLevelFiveTitle
        }
    }

    var details: LocalizedStringResource {
        switch self {
        case .firstTask:
            return .achievementFirstTaskDescription
        case .taskMaster:
            return .achievementTaskMasterDescription
        case .eventGoer:
            return .achievementEventGoerDescription
        case .ecoReader:
            return .achievementEcoReaderDescription
        case .communityMember:
            return .achievementCommunityMemberDescription
        case .levelFive:
            return .achievementLevelFiveDescription
        }
    }
}
