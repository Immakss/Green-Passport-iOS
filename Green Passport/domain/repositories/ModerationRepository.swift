import Foundation

protocol ModerationRepository {
    func observeIsAdmin(userId: String) -> AsyncThrowingStream<Bool, Error>
    func reportPost(postId: String, reporterId: String, reason: ReportReason) async throws
    func observePendingSubmissions() -> AsyncThrowingStream<[TaskSubmission], Error>
    func observeFlaggedPosts() -> AsyncThrowingStream<[ForumPost], Error>
    func reviewSubmission(submissionId: String, approve: Bool, reason: String?) async throws
    func moderatePost(postId: String, action: ModerationAction) async throws
}
