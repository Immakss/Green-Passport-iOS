import SwiftUI

struct QrScannerScreen: View {
    var hint: LocalizedStringResource = .pointCameraAtTaskQrCodeMsg
    let onCode: (String) -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            if QrScannerView.isAvailable {
                QrScannerView(onCode: onCode)
                    .ignoresSafeArea()
                Text(hint)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(Spacing.medium)
                    .glassEffect(in: .rect(cornerRadius: CornerRadius.large))
                    .padding(Spacing.large)
            } else {
                StateView(kind: .empty(message: .qrScannerUnavailableMsg))
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(role: .close, action: onClose)
                .buttonStyle(.glass)
                .padding(Spacing.medium)
        }
    }
}
