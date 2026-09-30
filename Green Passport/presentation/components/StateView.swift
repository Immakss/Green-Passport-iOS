import SwiftUI

struct StateView: View {
    private static let mascotSize: CGFloat = 120

    let kind: StateViewKind

    var body: some View {
        VStack(spacing: Spacing.medium) {
            switch kind {
            case .loading:
                ProgressView()
                    .controlSize(.large)
            case .empty(let message):
                MascotImage(size: Self.mascotSize)
                Text(message)
                    .font(.body)
                    .foregroundStyle(Palette.secondaryText)
                    .multilineTextAlignment(.center)
            case .error(let retry):
                MascotImage(size: Self.mascotSize)
                Text(.errorGenericMessage)
                    .font(.body)
                    .foregroundStyle(Palette.secondaryText)
                    .multilineTextAlignment(.center)
                Button(action: retry) {
                    Text(.retryButton)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StateView(kind: .error(retry: {}))
}
