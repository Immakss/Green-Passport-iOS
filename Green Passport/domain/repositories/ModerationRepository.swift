protocol ModerationRepository {
    func observeIsAdmin(userId: String) -> AsyncThrowingStream<Bool, Error>
    func reportPost(postId: String, reporterId: String, reason: ReportReason) async throws
}
