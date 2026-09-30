final class ReviewSubmissionUseCase {
    private let moderationRepository: ModerationRepository

    init(moderationRepository: ModerationRepository) {
        self.moderationRepository = moderationRepository
    }

    func execute(submissionId: String, approve: Bool, reason: String?) async throws {
        try await moderationRepository.reviewSubmission(submissionId: submissionId, approve: approve, reason: reason)
    }
}
