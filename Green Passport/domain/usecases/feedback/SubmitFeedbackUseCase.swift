final class SubmitFeedbackUseCase {
    private let feedbackRepository: FeedbackRepository
    private let textModerator: TextModerator

    init(feedbackRepository: FeedbackRepository, textModerator: TextModerator) {
        self.feedbackRepository = feedbackRepository
        self.textModerator = textModerator
    }

    func execute(userId: String, type: FeedbackType, message: String, rating: Int?) async throws {
        guard textModerator.isAllowed(message) else {
            throw ContentRejectedError()
        }
        try await feedbackRepository.submitFeedback(FeedbackEntry(userId: userId, type: type, message: message, rating: rating))
    }
}
