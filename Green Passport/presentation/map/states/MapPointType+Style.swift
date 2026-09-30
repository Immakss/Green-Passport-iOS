import Foundation

extension MapPointType {
    var title: LocalizedStringResource {
        switch self {
        case .ecoShop:
            return .mapTypeEcoShop
        case .recyclingPoint:
            return .mapTypeRecyclingPoint
        case .ecoEvent:
            return .mapTypeEcoEvent
        }
    }

    var systemImage: String {
        switch self {
        case .ecoShop:
            return "storefront.fill"
        case .recyclingPoint:
            return "arrow.3.trianglepath"
        case .ecoEvent:
            return "calendar"
        }
    }

}
