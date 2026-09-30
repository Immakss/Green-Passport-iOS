final class FetchActiveSurveyUseCase {
    private let feedbackRepository: FeedbackRepository

    init(feedbackRepository: FeedbackRepository) {
        self.feedbackRepository = feedbackRepository
    }

    func execute() async throws -> SurveyQuestion? {
        return try await feedbackRepository.fetchActiveSurvey()
    }
}
