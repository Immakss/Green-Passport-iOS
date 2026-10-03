import Foundation

nonisolated enum ContentLanguage {
    private static let fallbackCode = "ru"

    static var current: String {
        return Bundle.main.preferredLocalizations.first ?? fallbackCode
    }
}
