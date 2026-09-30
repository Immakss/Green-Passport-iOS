import Foundation

final class UserDefaultsSettingsRepository: SettingsRepository {
    private static let onboardingSeenKey = "onboarding_seen"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isOnboardingSeen: Bool {
        return defaults.bool(forKey: Self.onboardingSeenKey)
    }

    func markOnboardingSeen() {
        defaults.set(true, forKey: Self.onboardingSeenKey)
    }
}
