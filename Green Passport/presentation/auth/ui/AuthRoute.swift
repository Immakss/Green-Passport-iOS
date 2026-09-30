import SwiftUI

struct AuthRoute: View {
    @State private var viewModel: AuthViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildAuthViewModel())
    }

    var body: some View {
        AuthScreen(
            uiState: viewModel.uiState,
            onAction: viewModel.handle,
            onAppleRequest: viewModel.prepareAppleRequest,
            onAppleCompletion: viewModel.completeAppleRequest
        )
    }
}
