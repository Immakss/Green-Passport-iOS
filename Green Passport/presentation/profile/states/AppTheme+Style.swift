import SwiftUI

extension AppTheme {
    var title: LocalizedStringResource {
        switch self {
        case .system:
            return .systemTheme
        case .light:
            return .lightTheme
        case .dark:
            return .darkTheme
        }
    }

    var systemImage: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
