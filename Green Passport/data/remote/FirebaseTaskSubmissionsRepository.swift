import FirebaseFirestore
import FirebaseStorage
import Foundation

final class FirebaseTaskSubmissionsRepository: TaskSubmissionsRepository {
    private static let fieldTaskId = "taskId"
    private static let fieldUserId = "userId"
    private static let fieldUserName = "userName"
    private static let fieldPhotoPath = "photoPath"
    private static let fieldStatus = "status"
    private static let fieldRejectionReason = "rejectionReason"
    private static let fieldCreatedAt = "createdAtEpochMillis"
    private static let submissionsFolder = "greenpassport/submissions"
    private static let jpegContentType = "image/jpeg"

    private let firestore: Firestore
    private let storage: Storage

    init(firestore: Firestore, storage: Storage) {
        self.firestore = firestore
        self.storage = storage
    }

    func observeUserSubmissions(userId: String) -> AsyncThrowingStream<[TaskSubmission], Error> {
        let query = FirestoreCollections.taskSubmissions(firestore).whereField(Self.fieldUserId, isEqualTo: userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return snapshot.documents.compactMap(Self.submission(from:))
        }
    }

    func submitPhoto(userId: String, userName: String?, taskId: String, jpegData: Data) async throws -> TaskSubmission {
        let photoPath = "\(Self.submissionsFolder)/\(userId)/\(UUID().uuidString).jpg"
        let metadata = StorageMetadata()
        metadata.contentType = Self.jpegContentType
        _ = try await storage.reference(withPath: photoPath).putDataAsync(jpegData, metadata: metadata)
        let createdAt = EpochMillis.now
        let submission = TaskSubmission(
            id: "\(userId)_\(taskId)",
            taskId: taskId,
            userId: userId,
            userName: userName,
            photoPath: photoPath,
            status: .pending,
            rejectionReason: nil,
            createdAt: EpochMillis.date(from: createdAt)
        )
        let data: [String: Any] = [
            Self.fieldTaskId: taskId,
            Self.fieldUserId: userId,
            Self.fieldUserName: userName ?? NSNull(),
            Self.fieldPhotoPath: photoPath,
            Self.fieldStatus: SubmissionStatus.pending.rawValue,
            Self.fieldRejectionReason: NSNull(),
            Self.fieldCreatedAt: createdAt,
        ]
        try await FirestoreCollections.taskSubmissions(firestore).document(submission.id).setData(data)
        return submission
    }

    func photoUrl(photoPath: String) async throws -> URL {
        return try await storage.reference(withPath: photoPath).downloadURL()
    }

    static func submission(from document: DocumentSnapshot) -> TaskSubmission? {
        guard let taskId = document.string(fieldTaskId),
              let userId = document.string(fieldUserId),
              let photoPath = document.string(fieldPhotoPath),
              let status = document.string(fieldStatus).flatMap(SubmissionStatus.init(rawValue:)) else {
            return nil
        }
        return TaskSubmission(
            id: document.documentID,
            taskId: taskId,
            userId: userId,
            userName: document.string(fieldUserName),
            photoPath: photoPath,
            status: status,
            rejectionReason: document.string(fieldRejectionReason),
            createdAt: document.date(fieldCreatedAt) ?? .distantPast
        )
    }
}
