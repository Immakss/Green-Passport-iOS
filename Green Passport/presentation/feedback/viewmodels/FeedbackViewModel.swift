import Foundation
import Observation

@Observable
final class FeedbackViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let submitFeedback: SubmitFeedbackUseCase
    @ObservationIgnored private let fetchActiveSurvey: FetchActiveSurveyUseCase
    @ObservationIgnored private let hasAnsweredSurvey: HasAnsweredSurveyUseCase
    @ObservationIgnored private let submitSurveyAnswer: SubmitSurveyAnswerUseCase
    @ObservationIgnored private var userId: String?

    var uiState = FeedbackUiState()

    init(
        observeSession: ObserveSessionUseCase,
        submitFeedback: SubmitFeedbackUseCase,
        fetchActiveSurvey: FetchActiveSurveyUseCase,
        hasAnsweredSurvey: HasAnsweredSurveyUseCase,
        submitSurveyAnswer: SubmitSurveyAnswerUseCase
    ) {
        self.observeSession = observeSession
        self.submitFeedback = submitFeedback
        self.fetchActiveSurvey = fetchActiveSurvey
        self.hasAnsweredSurvey = hasAnsweredSurvey
        self.submitSurveyAnswer = submitSurveyAnswer
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            await load()
        }
    }

    func load() async {
        uiState.hasError = false
        do {
            let survey = try await fetchActiveSurvey.execute()
            var answered = false
            if let survey, let userId {
                answered = try await hasAnsweredSurvey.execute(userId: userId, surveyId: survey.id)
            }
            uiState.survey = survey
            uiState.hasAnsweredSurvey = answered
        } catch {
            uiState.hasError = true
        }
        uiState.isLoading = false
    }

    func submitReview() {
        guard let userId, uiState.rating > 0, !uiState.isSubmittingReview else {
            return
        }
        uiState.isSubmittingReview = true
        uiState.isReviewRejected = false
        let message = uiState.reviewMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let rating = uiState.rating
        Task {
            do {
                try await submitFeedback.execute(userId: userId, type: .review, message: message, rating: rating)
                uiState.reviewSubmitted = true
            } catch is ContentRejectedError {
                uiState.isReviewRejected = true
            } catch {
                uiState.reviewSubmitted = false
            }
            uiState.isSubmittingReview = false
        }
    }

    func submitSuggestion() {
        let message = uiState.suggestionMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let userId, !message.isEmpty, !uiState.isSubmittingSuggestion else {
            return
        }
        uiState.isSubmittingSuggestion = true
        uiState.isSuggestionRejected = false
        Task {
            do {
                try await submitFeedback.execute(userId: userId, type: .suggestion, message: message, rating: nil)
                uiState.suggestionSubmitted = true
            } catch is ContentRejectedError {
                uiState.isSuggestionRejected = true
            } catch {
                uiState.suggestionSubmitted = false
            }
            uiState.isSubmittingSuggestion = false
        }
    }

    func answerSurvey(optionIndex: Int) {
        guard let userId, let survey = uiState.survey, !uiState.hasAnsweredSurvey, !uiState.isSubmittingSurveyAnswer else {
            return
        }
        uiState.isSubmittingSurveyAnswer = true
        Task {
            do {
                try await submitSurveyAnswer.execute(userId: userId, surveyId: survey.id, optionIndex: optionIndex)
                uiState.hasAnsweredSurvey = true
            } catch {
                uiState.hasAnsweredSurvey = false
            }
            uiState.isSubmittingSurveyAnswer = false
        }
    }
}
