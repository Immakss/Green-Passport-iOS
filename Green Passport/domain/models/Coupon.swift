import Foundation

nonisolated struct Coupon: Identifiable, Hashable, Sendable {
    let id: String
    let rewardId: String
    let redeemedAt: Date
    let expiresAt: Date?
}
