import Foundation

nonisolated struct Coupon: Identifiable, Hashable, Sendable {
    let id: String
    let rewardId: String
    let code: String?
    let redeemedAt: Date
    let expiresAt: Date?
    let usedAt: Date?

    func status(at date: Date) -> CouponStatus {
        if usedAt != nil {
            return .used
        }
        if let expiresAt, expiresAt < date {
            return .expired
        }
        return .active
    }
}
