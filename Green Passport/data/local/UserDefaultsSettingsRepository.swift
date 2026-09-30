import Foundation

final class UserDefaultsSettingsRepository: SettingsRepository {
    private static let onboardingSeenKey = "onboarding_seen"
    private static let notificationsEnabledKey = "notifications_enabled"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isOnboardingSeen: Bool {
        return defaults.bool(forKey: Self.onboardingSeenKey)
    }

    var isNotificationsEnabled: Bool {
        return defaults.object(forKey: Self.notificationsEnabledKey) as? Bool ?? true
    }

    func setNotificationsEnabled(_ isEnabled: Bool) {
        defaults.set(isEnabled, forKey: Self.notificationsEnabledKey)
    }

    func markOnboardingSeen() {
        defaults.set(true, forKey: Self.onboardingSeenKey)
    }
}
