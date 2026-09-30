import Foundation

extension CouponItem {
    private static let dayLength: TimeInterval = 24 * 60 * 60

    static let expiringSoonDays = 3

    func daysLeft(at date: Date) -> Int? {
        guard let expiresAt = coupon.expiresAt else {
            return nil
        }
        return max(0, Int(ceil(expiresAt.timeIntervalSince(date) / Self.dayLength)))
    }

    func isExpiringSoon(at date: Date) -> Bool {
        guard coupon.status(at: date) == .active, let daysLeft = daysLeft(at: date) else {
            return false
        }
        return daysLeft <= Self.expiringSoonDays
    }

    func statusText(at date: Date) -> String {
        switch coupon.status(at: date) {
        case .active:
            if isExpiringSoon(at: date), let daysLeft = daysLeft(at: date) {
                return String(localized: .daysLeft(daysLeft))
            }
            guard let expiresAt = coupon.expiresAt else {
                return String(localized: .noExpiryDate)
            }
            return String(localized: .validUntil(expiresAt.formatted(date: .long, time: .omitted)))
        case .used:
            let usedAt = coupon.usedAt ?? coupon.redeemedAt
            return String(localized: .usedOn(usedAt.formatted(date: .abbreviated, time: .omitted)))
        case .expired:
            let expiresAt = coupon.expiresAt ?? coupon.redeemedAt
            return String(localized: .expiredOn(expiresAt.formatted(date: .abbreviated, time: .omitted)))
        }
    }
}
