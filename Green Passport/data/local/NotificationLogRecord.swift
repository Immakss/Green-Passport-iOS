import Foundation
import SwiftData

@Model
final class NotificationLogRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var body: String
    var sentAt: Date

    init(id: UUID, title: String, body: String, sentAt: Date) {
        self.id = id
        self.title = title
        self.body = body
        self.sentAt = sentAt
    }
}
