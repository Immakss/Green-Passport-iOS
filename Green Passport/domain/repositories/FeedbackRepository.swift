protocol FeedbackRepository {
    func fetchActiveSurvey() async throws -> SurveyQuestion?
    func hasAnsweredSurvey(userId: String, surveyId: String) async throws -> Bool
}
