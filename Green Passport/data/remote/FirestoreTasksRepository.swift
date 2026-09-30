import FirebaseFirestore

final class FirestoreTasksRepository: TasksRepository {
    private static let fieldTitle = "title"
    private static let fieldDescription = "description"
    private static let fieldCategory = "category"
    private static let fieldCity = "city"
    private static let fieldRewardPoints = "rewardPoints"
    private static let fieldRewardXp = "rewardXp"
    private static let fieldImageUrl = "imageUrl"
    private static let fieldVerification = "verification"
    private static let fieldUserId = "userId"
    private static let fieldTaskId = "taskId"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func fetchTasks() async throws -> [EcoTask] {
        let snapshot = try await FirestoreCollections.tasks(firestore).getDocuments()
        return snapshot.documents.compactMap(Self.task(from:))
    }

    func fetchCompletedTaskIds(userId: String) async throws -> Set<String> {
        let snapshot = try await FirestoreCollections.taskProgress(firestore)
            .whereField(Self.fieldUserId, isEqualTo: userId)
            .getDocuments()
        return Set(snapshot.documents.compactMap { return $0.string(Self.fieldTaskId) })
    }

    private static func task(from document: DocumentSnapshot) -> EcoTask? {
        guard let title = document.string(fieldTitle),
              let description = document.string(fieldDescription),
              let category = document.string(fieldCategory).flatMap(TaskCategory.init(rawValue:)),
              let city = document.string(fieldCity) else {
            return nil
        }
        return EcoTask(
            id: document.documentID,
            title: title,
            description: description,
            category: category,
            city: city,
            rewardPoints: document.int(fieldRewardPoints) ?? 0,
            rewardXp: document.int(fieldRewardXp) ?? 0,
            imageUrl: document.string(fieldImageUrl),
            verification: document.string(fieldVerification).flatMap(TaskVerification.init(rawValue:)) ?? .selfReported
        )
    }
}
