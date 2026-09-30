import SwiftUI

struct EventDetailRoute: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EventDetailViewModel
    @State private var isScannerPresented = false

    init(eventId: String, container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildEventDetailViewModel(eventId: eventId))
    }

    var body: some View {
        NavigationStack {
            EventDetailScreen(
                uiState: viewModel.uiState,
                onSignUp: viewModel.signUp,
                onCheckIn: { isScannerPresented = true },
                onRetry: viewModel.retry
            )
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
        .fullScreenCover(isPresented: $isScannerPresented) {
            QrScannerScreen(
                hint: .pointCameraAtEventQrCodeMsg,
                onCode: { code in
                    isScannerPresented = false
                    viewModel.checkIn(code: code)
                },
                onClose: { isScannerPresented = false }
            )
        }
    }
}
