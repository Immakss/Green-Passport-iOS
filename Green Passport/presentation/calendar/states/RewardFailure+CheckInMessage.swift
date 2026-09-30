import Foundation

extension RewardFailure {
    var checkInMessage: LocalizedStringResource {
        switch self {
        case .invalidCode:
            return .eventCodeDoesNotMatchMsg
        case .wrongVerification:
            return .checkInWindowMsg
        case .alreadyCompleted:
            return .checkedInAtEvent
        case .network:
            return .noInternetConnection
        default:
            return .somethingWentWrongMsg
        }
    }
}
