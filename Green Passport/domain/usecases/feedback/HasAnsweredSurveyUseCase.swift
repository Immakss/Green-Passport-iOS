final class HasAnsweredSurveyUseCase {
    private let feedbackRepository: FeedbackRepository

    init(feedbackRepository: FeedbackRepository) {
        self.feedbackRepository = feedbackRepository
    }

    func execute(userId: String, surveyId: String) async throws -> Bool {
        return try await feedbackRepository.hasAnsweredSurvey(userId: userId, surveyId: surveyId)
    }
}
