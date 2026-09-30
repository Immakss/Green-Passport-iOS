import SwiftUI

struct ProfileSetupRoute: View {
    let isEditing: Bool
    let onClose: () -> Void

    @State private var viewModel: ProfileSetupViewModel

    init(container: AppDIContainer, isEditing: Bool, onClose: @escaping () -> Void) {
        self.isEditing = isEditing
        self.onClose = onClose
        _viewModel = State(initialValue: container.buildProfileSetupViewModel())
    }

    var body: some View {
        ProfileSetupScreen(
            uiState: viewModel.uiState,
            isEditing: isEditing,
            onAction: viewModel.handle,
            onClose: onClose
        )
        .task {
            await viewModel.observe()
        }
        .onChange(of: viewModel.uiState.isSaved) { _, isSaved in
            if isSaved && isEditing {
                onClose()
            }
        }
    }
}
