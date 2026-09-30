final class SubmitSurveyAnswerUseCase {
    private let rewardsRepository: RewardsRepository

    init(rewardsRepository: RewardsRepository) {
        self.rewardsRepository = rewardsRepository
    }

    func execute(surveyId: String, optionIndex: Int) async throws -> RewardResult {
        return try await rewardsRepository.submitSurveyAnswer(surveyId: surveyId, optionIndex: optionIndex)
    }
}
