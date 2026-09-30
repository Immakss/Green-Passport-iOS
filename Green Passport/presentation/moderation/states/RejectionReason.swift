import Foundation

enum RejectionReason: CaseIterable {
    case taskNotVisible
    case notTakenByUser
    case inappropriate

    var title: LocalizedStringResource {
        switch self {
        case .taskNotVisible:
            return .taskNotVisibleInPhoto
        case .notTakenByUser:
            return .photoNotTakenByUser
        case .inappropriate:
            return .inappropriatePhoto
        }
    }
}
