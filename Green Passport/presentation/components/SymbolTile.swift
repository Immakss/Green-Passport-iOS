import SwiftUI

struct SymbolTile: View {
    private static let symbolScale: CGFloat = 0.5
    private static let cornerScale: CGFloat = 0.28

    let systemImage: String
    let color: Color
    var size: CGFloat = 32

    var body: some View {
        RoundedRectangle(cornerRadius: size * Self.cornerScale, style: .continuous)
            .fill(color.gradient)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: systemImage)
                    .font(.system(size: size * Self.symbolScale, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        SymbolTile(systemImage: "person.3.fill", color: SectionColor.community)
        SymbolTile(systemImage: "gamecontroller.fill", color: SectionColor.games, size: 56)
    }
}
