import SwiftUI

struct OnboardingScreen: View {
    private static let mascotSize: CGFloat = 220
    private static let haloSize: CGFloat = 280

    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: Spacing.large) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Palette.mintSurface)
                    .frame(width: Self.haloSize, height: Self.haloSize)
                MascotImage(size: Self.mascotSize)
            }
            VStack(spacing: Spacing.small) {
                Text(.onboardingTitle)
                    .font(.largeTitle.bold())
                Text(.onboardingSubtitle)
                    .font(.body)
                    .foregroundStyle(Palette.secondaryText)
            }
            .multilineTextAlignment(.center)
            Spacer()
            AppButton(title: .onboardingGetStarted, action: onGetStarted)
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.bottom, Spacing.medium)
        .background(Palette.screenBackground)
    }
}

#Preview {
    OnboardingScreen(onGetStarted: {})
}
