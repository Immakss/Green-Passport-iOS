protocol NotificationPermission {
    func requestIfNeeded() async -> Bool
}
