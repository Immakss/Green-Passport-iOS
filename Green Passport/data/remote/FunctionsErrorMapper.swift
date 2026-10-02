import FirebaseFunctions
import Foundation

enum FunctionsErrorMapper {
    private static let notEnoughPointsMarker = "Not enough points"
    private static let serverMessageFailures: [(marker: String, failure: RewardFailure)] = [
        (marker: "qr_not_active", failure: .qrCodeNotActive),
        (marker: "qr_limit_reached", failure: .qrCodeLimitReached),
        (marker: "reward_sold_out", failure: .rewardSoldOut),
    ]

    static func failure(from error: Error) -> RewardFailure {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        guard nsError.domain == FunctionsErrorDomain, let code = FunctionsErrorCode(rawValue: nsError.code) else {
            return .unknown
        }
        if let known = serverMessageFailures.first(where: { return nsError.localizedDescription.contains($0.marker) }) {
            return known.failure
        }
        switch code {
        case .resourceExhausted:
            return .dailyLimitReached
        case .alreadyExists:
            return .alreadyCompleted
        case .notFound:
            return .invalidCode
        case .failedPrecondition:
            return nsError.localizedDescription.contains(notEnoughPointsMarker) ? .notEnoughPoints : .wrongVerification
        case .unavailable:
            return .network
        default:
            return .unknown
        }
    }
}
