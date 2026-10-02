import SwiftUI

struct GameTileButtonStyle: ButtonStyle {
    private static let pressedScale: CGFloat = 0.92
    private static let pressedRotation = Angle.degrees(-3)
    private static let springResponse: Double = 0.3
    private static let springDamping: Double = 0.5

    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? Self.pressedScale : 1)
            .rotationEffect(configuration.isPressed ? Self.pressedRotation : .zero)
            .animation(.spring(response: Self.springResponse, dampingFraction: Self.springDamping), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, isPressed in
                return isPressed
            }
    }
}
