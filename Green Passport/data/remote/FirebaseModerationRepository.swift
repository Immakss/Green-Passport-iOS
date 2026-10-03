import FirebaseFirestore
import FirebaseFunctions
import Foundation

final class FirebaseModerationRepository: ModerationRepository {
    private static let fieldPostId = "postId"
    private static let fieldReporterId = "reporterId"
    private static let fieldReason = "reason"
    private static let fieldCreatedAt = "createdAtEpochMillis"
    private static let fieldStatus = "status"
    private static let fieldHidden = "hidden"
    private static let fieldReportCount = "reportCount"
    private static let paramSubmissionId = "submissionId"
    private static let paramApprove = "approve"
    private static let paramReason = "reason"
    private static let paramPostId = "postId"
    private static let paramAction = "action"

    private let firestore: Firestore
    private let functions: Functions

    init(firestore: Firestore, functions: Functions) {
        self.firestore = firestore
        self.functions = functions
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

    func observePendingSubmissions() -> AsyncThrowingStream<[TaskSubmission], Error> {
        let query = FirestoreCollections.taskSubmissions(firestore)
            .whereField(Self.fieldStatus, isEqualTo: SubmissionStatus.pending.rawValue)
        return FirestoreStream.mapped(FirestoreStream.snapshots(of: query)) { snapshot in
            return snapshot.documents
                .compactMap { return FirebaseTaskSubmissionsRepository.submission(from: $0) }
                .sorted { return $0.createdAt < $1.createdAt }
        }
    }

    func observeFlaggedPosts() -> AsyncThrowingStream<[ForumPost], Error> {
        let hiddenQuery = FirestoreCollections.posts(firestore).whereField(Self.fieldHidden, isEqualTo: true)
        let reportedQuery = FirestoreCollections.posts(firestore).whereField(Self.fieldReportCount, isGreaterThan: 0)
        return AsyncThrowingStream { continuation in
            let buffer = FlaggedPostsBuffer { posts in
                continuation.yield(posts)
            }
            let hiddenRegistration = hiddenQuery.addSnapshotListener { snapshot, _ in
                buffer.update(hidden: snapshot?.documents.compactMap { return FirestoreCommunityRepository.post(from: $0) } ?? [])
            }
            let reportedRegistration = reportedQuery.addSnapshotListener { snapshot, _ in
                buffer.update(reported: snapshot?.documents.compactMap { return FirestoreCommunityRepository.post(from: $0) } ?? [])
            }
            continuation.onTermination = { _ in
                hiddenRegistration.remove()
                reportedRegistration.remove()
            }
        }
    }

    func reviewSubmission(submissionId: String, approve: Bool, reason: String?) async throws {
        var data: [String: Any] = [Self.paramSubmissionId: submissionId, Self.paramApprove: approve]
        if let reason {
            data[Self.paramReason] = reason
        }
        try await call(.reviewSubmission, data: data)
    }

    func moderatePost(postId: String, action: ModerationAction) async throws {
        try await call(.moderateContent, data: [Self.paramPostId: postId, Self.paramAction: action.rawValue])
    }

    private func call(_ name: CloudFunctionName, data: [String: Any]) async throws {
        do {
            _ = try await functions.httpsCallable(name.rawValue).call(data)
        } catch {
            throw RewardFailureError(failure: FunctionsErrorMapper.failure(from: error))
        }
    }
}

private final class FlaggedPostsBuffer {
    private let onChange: ([ForumPost]) -> Void
    private var hidden: [ForumPost] = []
    private var reported: [ForumPost] = []

    init(onChange: @escaping ([ForumPost]) -> Void) {
        self.onChange = onChange
    }

    func update(hidden: [ForumPost]) {
        self.hidden = hidden
        emit()
    }

    func update(reported: [ForumPost]) {
        self.reported = reported
        emit()
    }

    private func emit() {
        let merged = Dictionary((hidden + reported).map { return ($0.id, $0) }) { first, _ in
            return first
        }
        onChange(merged.values.sorted { return $0.createdAt > $1.createdAt })
    }
}
