import Foundation

struct QuizQuestion {
    static let all: [QuizQuestion] = [
        QuizQuestion(text: .quizQuestion1, options: [.quizOptions10, .quizOptions11, .quizOptions12, .quizOptions13], correctOptionIndex: 2),
        QuizQuestion(text: .quizQuestion2, options: [.quizOptions20, .quizOptions21, .quizOptions22, .quizOptions23], correctOptionIndex: 1),
        QuizQuestion(text: .quizQuestion3, options: [.quizOptions30, .quizOptions31, .quizOptions32, .quizOptions33], correctOptionIndex: 1),
        QuizQuestion(text: .quizQuestion4, options: [.quizOptions40, .quizOptions41, .quizOptions42, .quizOptions43], correctOptionIndex: 2),
        QuizQuestion(text: .quizQuestion5, options: [.quizOptions50, .quizOptions51, .quizOptions52, .quizOptions53], correctOptionIndex: 1),
    ]

    let text: LocalizedStringResource
    let options: [LocalizedStringResource]
    let correctOptionIndex: Int
}
