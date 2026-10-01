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
            router.push(.moderation)
        case .themeSelected(let theme):
            viewModel.selectTheme(theme)
        case .notificationsToggled(let isEnabled):
            viewModel.toggleNotifications(isEnabled)
        case .language:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
        case .signOut:
            viewModel.performSignOut()
        case .retry:
            viewModel.retry()
        }
    }
}
