import SwiftUI

struct EventDetailRoute: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EventDetailViewModel

    init(eventId: String, container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildEventDetailViewModel(eventId: eventId))
    }

    var body: some View {
        NavigationStack {
            EventDetailScreen(uiState: viewModel.uiState, onSignUp: viewModel.signUp, onRetry: viewModel.retry)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .close) {
                            dismiss()
                        }
                    }
                }
        }
        .task {
            await viewModel.observe()
        }
    }
}
