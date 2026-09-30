import Foundation

enum CouponsTab: CaseIterable, Hashable {
    case active
    case used
    case expired

    var status: CouponStatus {
        switch self {
        case .active:
            return .active
        case .used:
            return .used
        case .expired:
            return .expired
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .active:
            return .couponsActive
        case .used:
            return .couponsUsed
        case .expired:
            return .couponsExpired
        }
    }

    var emptyMessage: LocalizedStringResource {
        switch self {
        case .active:
            return .noActiveCouponsMsg
        case .used:
            return .noUsedCoupons
        case .expired:
            return .noExpiredCoupons
        }
    }
}
