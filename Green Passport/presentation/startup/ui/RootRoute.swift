import SwiftUI

struct RootRoute: View {
    let container: AppDIContainer

    @State private var viewModel: RootViewModel

    init(container: AppDIContainer) {
        self.container = container
        _viewModel = State(initialValue: container.buildRootViewModel())
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                Palette.screenBackground
                    .ignoresSafeArea()
            case .needsOnboarding:
                OnboardingScreen(onGetStarted: viewModel.completeOnboarding)
                    .transition(.opacity)
            case .needsAuth:
                AuthRoute(container: container)
                    .transition(.opacity)
            case .needsProfile:
                ProfileSetupRoute(container: container, isEditing: false, onClose: {})
                    .transition(.opacity)
            case .ready:
                MainTabView(container: container)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.state)
        .task {
            await viewModel.observe()
        }
    }
}
