final class IsOnboardingSeenUseCase {
    private let settingsRepository: SettingsRepository

    init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }

    func execute() -> Bool {
        return settingsRepository.isOnboardingSeen
    }
}
