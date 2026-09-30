import Foundation

extension TaskCategory {
    var title: LocalizedStringResource {
        switch self {
        case .recycling:
            return .tasksCategoryRecycling
        case .cleanup:
            return .tasksCategoryCleanup
        case .transport:
            return .tasksCategoryTransport
        case .reusableItems:
            return .tasksCategoryReusableItems
        case .lecture:
            return .tasksCategoryLecture
        }
    }
}
