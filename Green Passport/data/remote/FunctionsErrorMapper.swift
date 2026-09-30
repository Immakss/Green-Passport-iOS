import FirebaseFunctions
import Foundation

enum FunctionsErrorMapper {
    private static let notEnoughPointsMarker = "Not enough points"

    static func failure(from error: Error) -> RewardFailure {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        guard nsError.domain == FunctionsErrorDomain, let code = FunctionsErrorCode(rawValue: nsError.code) else {
            return .unknown
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
