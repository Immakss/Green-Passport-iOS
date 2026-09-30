import Foundation
import SwiftData

final class SwiftDataNotificationLogRepository: NotificationLogRepository {
    private let context: ModelContext?

    init(container: ModelContainer?) {
        context = container?.mainContext
    }

    func log(title: String, body: String, sentAt: Date) {
        guard let context else {
            return
        }
        context.insert(NotificationLogRecord(id: UUID(), title: title, body: body, sentAt: sentAt))
        try? context.save()
    }

    func entries(before date: Date) -> [NotificationLogEntry] {
        let descriptor = FetchDescriptor<NotificationLogRecord>(
            predicate: #Predicate { $0.sentAt <= date },
            sortBy: [SortDescriptor(\.sentAt, order: .reverse)]
        )
        let records = (try? context?.fetch(descriptor)) ?? []
        return records.map { record in
            return NotificationLogEntry(id: record.id, title: record.title, body: record.body, sentAt: record.sentAt)
        }
    }
}
