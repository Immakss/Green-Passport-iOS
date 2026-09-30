import SwiftUI

struct NotificationsRoute: View {
    @State private var viewModel: NotificationsViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildNotificationsViewModel())
    }

    var body: some View {
        NotificationsScreen(entries: viewModel.entries)
            .onAppear(perform: viewModel.load)
            .refreshable {
                viewModel.load()
            }
    }
}
