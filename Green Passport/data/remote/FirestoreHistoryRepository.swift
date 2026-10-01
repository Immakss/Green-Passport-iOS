import FirebaseFirestore

final class FirestoreHistoryRepository: HistoryRepository {
    private static let fieldUserId = "userId"
    private static let fieldTaskId = "taskId"
    private static let fieldCompletedAt = "completedAtEpochMillis"
    private static let fieldEventId = "eventId"
    private static let fieldRegisteredAt = "registeredAtEpochMillis"

    private let firestore: Firestore
    private let tasksRepository: TasksRepository
    private let eventsRepository: EventsRepository
    private let shopRepository: ShopRepository

    init(
        firestore: Firestore,
        tasksRepository: TasksRepository,
        eventsRepository: EventsRepository,
        shopRepository: ShopRepository
    ) {
        self.firestore = firestore
        self.tasksRepository = tasksRepository
        self.eventsRepository = eventsRepository
        self.shopRepository = shopRepository
    }

    func fetchHistory(userId: String) async throws -> [HistoryEntry] {
        let taskTitles = Dictionary((try await tasksRepository.observeTasks().firstValue() ?? []).map { return ($0.id, $0.title) }) { first, _ in
            return first
        }
        let eventTitles = Dictionary((try await eventsRepository.observeEvents().firstValue() ?? []).map { return ($0.id, $0.title) }) { first, _ in
            return first
        }
        let rewardTitles = Dictionary((try await shopRepository.observeRewards().firstValue() ?? []).map { return ($0.id, $0.title) }) { first, _ in
            return first
        }
        let taskEntries = try await FirestoreCollections.taskProgress(firestore)
            .whereField(Self.fieldUserId, isEqualTo: userId)
            .getDocuments()
            .documents
            .compactMap { document -> HistoryEntry? in
                guard let taskId = document.string(Self.fieldTaskId),
                      let completedAt = document.date(Self.fieldCompletedAt) else {
                    return nil
                }
                return HistoryEntry(
                    id: document.documentID,
                    type: .taskCompleted,
                    title: taskTitles[taskId] ?? taskId,
                    timestamp: completedAt
                )
            }
        let eventEntries = try await FirestoreCollections.eventRegistrations(firestore)
            .whereField(Self.fieldUserId, isEqualTo: userId)
            .getDocuments()
            .documents
            .compactMap { document -> HistoryEntry? in
                guard let eventId = document.string(Self.fieldEventId),
                      let registeredAt = document.date(Self.fieldRegisteredAt) else {
                    return nil
                }
                return HistoryEntry(
                    id: document.documentID,
                    type: .eventAttended,
                    title: eventTitles[eventId] ?? eventId,
                    timestamp: registeredAt
                )
            }
        let rewardEntries = (try await shopRepository.observePurchases(userId: userId).firstValue() ?? []).map { coupon in
            return HistoryEntry(
                id: coupon.id,
                type: .rewardRedeemed,
                title: rewardTitles[coupon.rewardId] ?? coupon.rewardId,
                timestamp: coupon.redeemedAt
            )
        }
        return (taskEntries + eventEntries + rewardEntries).sorted { return $0.timestamp > $1.timestamp }
    }
}
