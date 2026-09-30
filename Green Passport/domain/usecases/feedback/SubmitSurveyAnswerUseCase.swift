final class SubmitSurveyAnswerUseCase {
    private let feedbackRepository: FeedbackRepository

    init(feedbackRepository: FeedbackRepository) {
        self.feedbackRepository = feedbackRepository
    }

    func execute(userId: String, surveyId: String, optionIndex: Int) async throws {
        try await feedbackRepository.submitSurveyAnswer(userId: userId, surveyId: surveyId, optionIndex: optionIndex)
    }
}
