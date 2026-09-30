import SwiftUI

struct AppButton: View {
    let title: LocalizedStringResource
    var isLoading = false
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.headline)
                    .opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                        .tint(Palette.onForest)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack {
        AppButton(title: .next) {}
        AppButton(title: .next, isLoading: true) {}
    }
    .padding()
}
