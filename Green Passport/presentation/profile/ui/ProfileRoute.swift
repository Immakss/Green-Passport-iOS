import SwiftUI

struct ProfileRoute: View {
    let container: AppDIContainer

    @Environment(TabRouter.self) private var router
    @Environment(\.openURL) private var openURL
    @State private var viewModel: ProfileViewModel
    @State private var isEditingProfile = false

    init(container: AppDIContainer) {
        self.container = container
        _viewModel = State(initialValue: container.buildProfileViewModel())
    }

    var body: some View {
        ProfileScreen(uiState: viewModel.uiState, languageName: AppLanguage.currentName, onAction: handle)
            .task {
                await viewModel.observe()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .fullScreenCover(isPresented: $isEditingProfile) {
                ProfileSetupRoute(container: container, isEditing: true) {
                    isEditingProfile = false
                }
            }
    }

    private func handle(_ action: ProfileUserAction) {
        switch action {
        case .open(let destination):
            router.push(destination)
        case .editProfile:
            isEditingProfile = true
        case .moderation:
            break
        case .language:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
        case .signOut:
            viewModel.performSignOut()
        case .retry:
            Task { await viewModel.refresh() }
        }
    }
}
