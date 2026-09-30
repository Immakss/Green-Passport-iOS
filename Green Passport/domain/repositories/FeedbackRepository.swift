protocol FeedbackRepository {
    func submitFeedback(_ entry: FeedbackEntry) async throws
    func fetchActiveSurvey() async throws -> SurveyQuestion?
    func hasAnsweredSurvey(userId: String, surveyId: String) async throws -> Bool
    func submitSurveyAnswer(userId: String, surveyId: String, optionIndex: Int) async throws
}
