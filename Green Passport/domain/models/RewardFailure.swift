nonisolated enum RewardFailure: Hashable, Sendable {
    case dailyLimitReached
    case alreadyCompleted
    case invalidCode
    case notEnoughPoints
    case wrongVerification
    case qrCodeNotActive
    case qrCodeLimitReached
    case rewardSoldOut
    case network
    case unknown
}
