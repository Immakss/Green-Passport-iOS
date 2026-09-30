import SwiftUI

struct ProfileAvatar: View {
    private static let mascotScale: CGFloat = 0.78

    let style: AvatarStyle
    var size: CGFloat = 44

    var body: some View {
        Circle()
            .fill(style.color)
            .frame(width: size, height: size)
            .overlay {
                MascotImage(size: size * Self.mascotScale)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        ForEach(AvatarStyle.allCases, id: \.self) { style in
            ProfileAvatar(style: style)
        }
    }
}
