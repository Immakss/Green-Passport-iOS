final class ObserveIsModeratorUseCase {
    private let moderationRepository: ModerationRepository

    init(moderationRepository: ModerationRepository) {
        self.moderationRepository = moderationRepository
    }

    func execute(userId: String) -> AsyncThrowingStream<Bool, Error> {
        return moderationRepository.observeIsAdmin(userId: userId)
    }
}
