import Foundation

extension RewardFailure {
    var message: LocalizedStringResource {
        switch self {
        case .dailyLimitReached:
            return .dailyLimitReachedMsg
        case .alreadyCompleted:
            return .taskAlreadyCompleted
        case .invalidCode:
            return .codeDoesNotMatchMsg
        case .wrongVerification:
            return .taskNeedsOtherConfirmationMsg
        case .qrCodeNotActive:
            return .qrCodeNotActiveMsg
        case .qrCodeLimitReached:
            return .qrCodeLimitReachedMsg
        case .network:
            return .noInternetForPointsMsg
        case .notEnoughPoints, .rewardSoldOut, .unknown:
            return .somethingWentWrongMsg
        }
    }
}
