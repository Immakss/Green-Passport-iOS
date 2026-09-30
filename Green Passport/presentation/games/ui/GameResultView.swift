import SwiftUI

struct GameResultView: View {
    private static let mascotSize: CGFloat = 140

    let message: String
    let onPlayAgain: () -> Void

    var body: some View {
        VStack(spacing: Spacing.large) {
            MascotImage(size: Self.mascotSize)
            Text(message)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
            AppButton(title: .gamePlayAgain, action: onPlayAgain)
        }
        .padding(Spacing.screenHorizontal)
        .transition(.scale.combined(with: .opacity))
    }
}
