final class MarkOnboardingSeenUseCase {
    private let settingsRepository: SettingsRepository

    init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }

    func execute() {
        settingsRepository.markOnboardingSeen()
    }
}
