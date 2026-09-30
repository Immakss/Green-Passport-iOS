import SwiftData

enum LocalStore {
    static func makeContainer() -> ModelContainer? {
        return try? ModelContainer(for: GameProgressRecord.self, NotificationLogRecord.self)
    }
}
