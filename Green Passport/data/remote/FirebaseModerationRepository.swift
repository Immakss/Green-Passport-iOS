import FirebaseFirestore

final class FirebaseModerationRepository: ModerationRepository {
    private static let fieldPostId = "postId"
    private static let fieldReporterId = "reporterId"
    private static let fieldReason = "reason"
    private static let fieldCreatedAt = "createdAtEpochMillis"

    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func observeIsAdmin(userId: String) -> AsyncThrowingStream<Bool, Error> {
        let document = FirestoreCollections.admins(firestore).document(userId)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: document)) { snapshot in
            return snapshot.exists
        }
    }

    func reportPost(postId: String, reporterId: String, reason: ReportReason) async throws {
        let data: [String: Any] = [
            Self.fieldPostId: postId,
            Self.fieldReporterId: reporterId,
            Self.fieldReason: reason.rawValue,
            Self.fieldCreatedAt: EpochMillis.now,
        ]
        try await FirestoreCollections.reports(firestore).document("\(postId)_\(reporterId)").setData(data)
    }
}
