import Foundation

enum AppLanguage {
    private static let fallbackCode = "ru"

    static var currentName: String {
        let code = Bundle.main.preferredLocalizations.first ?? fallbackCode
        let locale = Locale(identifier: code)
        return locale.localizedString(forLanguageCode: code)?.capitalized(with: locale) ?? code
    }
}
