import Foundation

final class FetchNotificationLogUseCase {
    private let notificationLogRepository: NotificationLogRepository

    init(notificationLogRepository: NotificationLogRepository) {
        self.notificationLogRepository = notificationLogRepository
    }

    func execute() -> [NotificationLogEntry] {
        return notificationLogRepository.entries(before: Date())
    }
}
