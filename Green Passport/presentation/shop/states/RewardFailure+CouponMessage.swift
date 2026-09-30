import Foundation

extension RewardFailure {
    var couponMessage: LocalizedStringResource {
        switch self {
        case .alreadyCompleted:
            return .couponAlreadyUsed
        case .wrongVerification:
            return .couponExpired
        case .network:
            return .noInternetConnection
        default:
            return .somethingWentWrongMsg
        }
    }
}
