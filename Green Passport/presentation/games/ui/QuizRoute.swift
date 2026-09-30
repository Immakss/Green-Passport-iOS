import SwiftUI

struct QuizRoute: View {
    @State private var viewModel: QuizViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildQuizViewModel())
    }

    var body: some View {
        QuizScreen(uiState: viewModel.uiState, onSelect: viewModel.select, onRestart: viewModel.restart)
    }
}
