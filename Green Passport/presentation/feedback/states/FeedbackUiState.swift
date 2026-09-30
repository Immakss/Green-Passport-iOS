struct FeedbackUiState {
    var rating = 0
    var reviewMessage = ""
    var isSubmittingReview = false
    var reviewSubmitted = false
    var isReviewRejected = false
    var suggestionMessage = ""
    var isSubmittingSuggestion = false
    var suggestionSubmitted = false
    var isSuggestionRejected = false
    var survey: SurveyQuestion?
    var hasAnsweredSurvey = false
    var isSubmittingSurveyAnswer = false
    var isLoading = true
    var hasError = false
}
