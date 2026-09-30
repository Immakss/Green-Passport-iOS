import SwiftUI

struct StepIndicator: View {
    private static let dotSize: CGFloat = 8
    private static let activeDotWidth: CGFloat = 24

    let stepCount: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: Spacing.xSmall) {
            ForEach(0..<stepCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? Palette.forest : Palette.fieldBackground)
                    .frame(width: index == currentStep ? Self.activeDotWidth : Self.dotSize, height: Self.dotSize)
            }
        }
        .animation(.snappy, value: currentStep)
        .accessibilityElement()
        .accessibilityLabel(Text(.stepXOfY(currentStep + 1, stepCount)))
    }
}

#Preview {
    StepIndicator(stepCount: 5, currentStep: 1)
}
