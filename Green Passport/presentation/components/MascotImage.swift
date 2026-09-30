import SwiftUI

struct MascotImage: View {
    let size: CGFloat

    var body: some View {
        Image(.mascot)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#Preview {
    MascotImage(size: 120)
}
