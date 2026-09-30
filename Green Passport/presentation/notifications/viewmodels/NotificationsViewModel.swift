import Observation

@Observable
final class NotificationsViewModel {
    @ObservationIgnored private let fetchNotificationLog: FetchNotificationLogUseCase

    private(set) var entries: [NotificationLogEntry] = []

    init(fetchNotificationLog: FetchNotificationLogUseCase) {
        self.fetchNotificationLog = fetchNotificationLog
    }

    func load() {
        entries = fetchNotificationLog.execute()
    }
}
