import Foundation

final class UserDefaultsSettingsRepository: SettingsRepository {
    private static let onboardingSeenKey = "onboarding_seen"
    private static let notificationsEnabledKey = "notifications_enabled"
    static let themeKey = "app_theme"

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

    var theme: AppTheme {
        return defaults.string(forKey: Self.themeKey).flatMap(AppTheme.init(rawValue:)) ?? .system
    }

    func setTheme(_ theme: AppTheme) {
        defaults.set(theme.rawValue, forKey: Self.themeKey)
    }

    func setNotificationsEnabled(_ isEnabled: Bool) {
        defaults.set(isEnabled, forKey: Self.notificationsEnabledKey)
    }

    func markOnboardingSeen() {
        defaults.set(true, forKey: Self.onboardingSeenKey)
    }
}
