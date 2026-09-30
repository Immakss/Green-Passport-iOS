import Foundation

extension ReportReason {
    var title: LocalizedStringResource {
        switch self {
        case .offensive:
            return .insultsOrObscenity
        case .spam:
            return .spam
        case .inappropriateImage:
            return .inappropriateContent
        case .other:
            return .other
        }
    }
}
