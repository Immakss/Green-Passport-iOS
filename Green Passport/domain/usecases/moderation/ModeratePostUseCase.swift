final class ModeratePostUseCase {
    private let moderationRepository: ModerationRepository

    init(moderationRepository: ModerationRepository) {
        self.moderationRepository = moderationRepository
    }

    func execute(postId: String, action: ModerationAction) async throws {
        try await moderationRepository.moderatePost(postId: postId, action: action)
    }
}
