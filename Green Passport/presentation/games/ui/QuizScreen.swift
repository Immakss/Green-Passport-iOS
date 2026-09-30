import SwiftUI

struct QuizScreen: View {
    private static let wrongOptionOpacity: Double = 0.15

    let uiState: QuizUiState
    let onSelect: (Int) -> Void
    let onRestart: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                if uiState.isFinished {
                    GameResultView(
                        message: String(localized: .quizFinishedFormat(uiState.correctAnswers, QuizQuestion.all.count)),
                        onPlayAgain: onRestart
                    )
                    .frame(maxWidth: .infinity)
                } else {
                    Text(.quizScoreFormat(uiState.currentQuestionIndex + 1, QuizQuestion.all.count, uiState.score))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Palette.secondaryText)
                    ProgressView(value: Double(uiState.currentQuestionIndex), total: Double(QuizQuestion.all.count))
                        .tint(Palette.forest)
                    Text(uiState.currentQuestion.text)
                        .font(.title2.bold())
                        .id(uiState.currentQuestionIndex)
                        .transition(.push(from: .trailing))
                    VStack(spacing: Spacing.small) {
                        ForEach(Array(uiState.currentQuestion.options.enumerated()), id: \.offset) { index, option in
                            optionButton(index: index, title: option)
                        }
                    }
                }
            }
            .padding(Spacing.screenHorizontal)
            .animation(.snappy, value: uiState.currentQuestionIndex)
            .animation(.snappy, value: uiState.selectedOptionIndex)
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.gameEcoQuizTitle))
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(trigger: uiState.selectedOptionIndex) { _, selected in
            guard let selected else {
                return nil
            }
            return selected == uiState.currentQuestion.correctOptionIndex ? .success : .error
        }
    }

    private func optionButton(index: Int, title: LocalizedStringResource) -> some View {
        let isAnswered = uiState.selectedOptionIndex != nil
        let isCorrect = index == uiState.currentQuestion.correctOptionIndex
        let isSelected = index == uiState.selectedOptionIndex
        let background: Color
        if isAnswered && isCorrect {
            background = Palette.mintSurface
        } else if isAnswered && isSelected {
            background = Palette.error.opacity(Self.wrongOptionOpacity)
        } else {
            background = Palette.cardBackground
        }
        return Button {
            onSelect(index)
        } label: {
            HStack {
                Text(title)
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.leading)
                Spacer()
                if isAnswered && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Palette.forest)
                } else if isAnswered && isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Palette.error)
                }
            }
            .foregroundStyle(Color.primary)
            .padding(Spacing.medium)
            .background(background, in: .rect(cornerRadius: CornerRadius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
    }
}

#Preview {
    NavigationStack {
        QuizScreen(uiState: QuizUiState(), onSelect: { _ in }, onRestart: {})
    }
}
