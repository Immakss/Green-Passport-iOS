struct QuizUiState {
    var currentQuestionIndex = 0
    var correctAnswers = 0
    var score = 0
    var selectedOptionIndex: Int?
    var isFinished = false

    var currentQuestion: QuizQuestion {
        return QuizQuestion.all[currentQuestionIndex]
    }
}
