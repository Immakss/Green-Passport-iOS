import SwiftUI

extension View {
    func loadingOverlay(_ isLoading: Bool, tint: Color? = nil) -> some View {
        return self
            .opacity(isLoading ? 0 : 1)
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(tint)
                }
            }
    }
}
