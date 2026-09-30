import Foundation

enum FavoritesSegment: Hashable, CaseIterable {
    case tasks
    case tips

    var title: LocalizedStringResource {
        switch self {
        case .tasks:
            return .tasks
        case .tips:
            return .tips
        }
    }
}
