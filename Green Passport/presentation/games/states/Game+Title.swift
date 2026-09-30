extension Game {
    private static let fallbackLanguage = "ru"

    var title: String {
        return titles[AppLanguage.currentCode] ?? titles[Self.fallbackLanguage] ?? id
    }
}
