import Foundation

extension TaskCategory {
    var interestTitle: LocalizedStringResource {
        switch self {
        case .recycling:
            return .recycling
        case .cleanup:
            return .cleanups
        case .transport:
            return .ecoTransport
        case .reusableItems:
            return .reusableItems
        case .lecture:
            return .lectures
        }
    }
}
