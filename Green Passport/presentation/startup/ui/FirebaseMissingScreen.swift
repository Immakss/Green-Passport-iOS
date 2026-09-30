import SwiftUI

struct FirebaseMissingScreen: View {
    private static let mascotSize: CGFloat = 160

    var body: some View {
        VStack(spacing: Spacing.medium) {
            MascotImage(size: Self.mascotSize)
            Text(.firebaseIsNotConfigured)
                .font(.title2.bold())
            Text(.addGoogleServiceInfoMsg)
                .font(.body)
                .foregroundStyle(Palette.secondaryText)
        }
        .multilineTextAlignment(.center)
        .padding(Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.screenBackground)
    }
}

#Preview {
    FirebaseMissingScreen()
}
