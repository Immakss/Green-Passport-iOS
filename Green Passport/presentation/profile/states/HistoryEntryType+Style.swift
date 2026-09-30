import Foundation

extension HistoryEntryType {
    var title: LocalizedStringResource {
        switch self {
        case .taskCompleted:
            return .historyTypeTaskCompleted
        case .eventAttended:
            return .historyTypeEventAttended
        case .rewardRedeemed:
            return .historyTypeRewardRedeemed
        }
    }

    var systemImage: String {
        switch self {
        case .taskCompleted:
            return "checkmark.circle.fill"
        case .eventAttended:
            return "calendar.badge.clock"
        case .rewardRedeemed:
            return "gift.fill"
        }
    }

}
