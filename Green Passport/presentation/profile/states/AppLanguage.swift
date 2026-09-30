import Foundation

enum AppLanguage {
    private static let fallbackCode = "ru"

    static var currentCode: String {
        return Bundle.main.preferredLocalizations.first ?? fallbackCode
    }

    static var currentName: String {
        let code = currentCode
        let locale = Locale(identifier: code)
        return locale.localizedString(forLanguageCode: code)?.capitalized(with: locale) ?? code
    }
}
