protocol NotificationPermission {
    func requestIfNeeded() async -> Bool
    func isAuthorized() async -> Bool
}
