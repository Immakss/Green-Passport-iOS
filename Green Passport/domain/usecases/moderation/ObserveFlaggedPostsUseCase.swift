final class ObserveFlaggedPostsUseCase {
    private let moderationRepository: ModerationRepository

    init(moderationRepository: ModerationRepository) {
        self.moderationRepository = moderationRepository
    }

    func execute() -> AsyncThrowingStream<[ForumPost], Error> {
        return moderationRepository.observeFlaggedPosts()
    }
}
