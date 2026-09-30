final class AppThemeUseCase {
    private let settingsRepository: SettingsRepository

    init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }

    func current() -> AppTheme {
        return settingsRepository.theme
    }

    func update(_ theme: AppTheme) {
        settingsRepository.setTheme(theme)
    }
}
