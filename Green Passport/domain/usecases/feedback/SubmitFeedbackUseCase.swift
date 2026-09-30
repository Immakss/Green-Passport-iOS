final class SubmitFeedbackUseCase {
    private let rewardsRepository: RewardsRepository
    private let textModerator: TextModerator

    init(rewardsRepository: RewardsRepository, textModerator: TextModerator) {
        self.rewardsRepository = rewardsRepository
        self.textModerator = textModerator
    }

    func execute(type: FeedbackType, message: String, rating: Int?) async throws -> RewardResult {
        guard textModerator.isAllowed(message) else {
            throw ContentRejectedError()
        }
        return try await rewardsRepository.submitFeedback(type: type, message: message, rating: rating)
    }
}
