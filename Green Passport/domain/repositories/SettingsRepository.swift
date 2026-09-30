protocol SettingsRepository {
    var isOnboardingSeen: Bool { get }
    func markOnboardingSeen()
}
