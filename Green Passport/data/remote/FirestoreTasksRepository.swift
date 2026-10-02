import FirebaseFirestore

final class FirestoreTasksRepository: TasksRepository {
    private static let fieldTitle = "title"
    private static let fieldDescription = "description"
    private static let fieldTitles = "titles"
    private static let fieldDescriptions = "descriptions"
    private static let fieldCategory = "category"
    private static let fieldCity = "city"
    private static let fieldRewardPoints = "rewardPoints"
    private static let fieldRewardXp = "rewardXp"
    private static let fieldImageUrl = "imageUrl"
    private static let fieldVerification = "verification"
    private static let fieldIsActive = "isActive"
    private static let fieldUserId = "userId"
    private static let fieldTaskId = "taskId"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeTasks() -> AsyncThrowingStream<[EcoTask], Error> {
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: FirestoreCollections.tasks(firestore))) { snapshot in
            return snapshot.documents.compactMap { return Self.task(from: $0) }
        }
    }

    func observeTask(id: String) -> AsyncThrowingStream<EcoTask?, Error> {
        let document = FirestoreCollections.tasks(firestore).document(id)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: document)) { snapshot in
            return Self.task(from: snapshot)
        }
    }

    func observeCompletedTaskIds(userId: String) -> AsyncThrowingStream<Set<String>, Error> {
        let query = FirestoreCollections.taskProgress(firestore).whereField(Self.fieldUserId, isEqualTo: userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return Set(snapshot.documents.compactMap { return $0.string(Self.fieldTaskId) })
        }
    }

    private static func task(from document: DocumentSnapshot) -> EcoTask? {
        guard let title = document.localizedString(fieldTitle, translations: fieldTitles),
              let description = document.localizedString(fieldDescription, translations: fieldDescriptions),
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
            verification: document.string(fieldVerification).flatMap(TaskVerification.init(rawValue:)) ?? .selfReported,
            isActive: document.bool(fieldIsActive) ?? true
        )
    }
}
