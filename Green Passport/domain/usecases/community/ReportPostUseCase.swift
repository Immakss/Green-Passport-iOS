final class ReportPostUseCase {
    private let moderationRepository: ModerationRepository

    init(moderationRepository: ModerationRepository) {
        self.moderationRepository = moderationRepository
    }

    func execute(postId: String, reporterId: String, reason: ReportReason) async throws {
        try await moderationRepository.reportPost(postId: postId, reporterId: reporterId, reason: reason)
    }
}
