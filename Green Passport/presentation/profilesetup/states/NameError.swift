import Foundation

enum NameError {
    case length
    case characters
    case inappropriate

    var message: LocalizedStringResource {
        switch self {
        case .length:
            return .nameFrom2To30Characters
        case .characters:
            return .nameLettersOnlyMsg
        case .inappropriate:
            return .textContainsBannedWords
        }
    }
}
