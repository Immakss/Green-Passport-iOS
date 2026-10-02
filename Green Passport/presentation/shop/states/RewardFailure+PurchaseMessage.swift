import Foundation

extension RewardFailure {
    var purchaseMessage: LocalizedStringResource {
        switch self {
        case .notEnoughPoints:
            return .shopInsufficientPoints
        case .rewardSoldOut:
            return .rewardSoldOut
        case .network:
            return .noInternetConnection
        default:
            return .somethingWentWrongMsg
        }
    }
}
