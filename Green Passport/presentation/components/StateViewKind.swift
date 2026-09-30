import SwiftUI

enum StateViewKind {
    case loading
    case empty(message: LocalizedStringResource)
    case error(retry: () -> Void)
}
