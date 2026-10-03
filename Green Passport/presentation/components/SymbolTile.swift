import SwiftUI

struct SymbolTile: View {
    static let defaultSymbolScale: CGFloat = 0.42
    private static let cornerScale: CGFloat = 0.28

    let systemImage: String
    var style: SymbolTileStyle = .accent
    var size: CGFloat = 32
    var symbolScale: CGFloat = SymbolTile.defaultSymbolScale

    var body: some View {
        RoundedRectangle(cornerRadius: size * Self.cornerScale, style: .continuous)
            .fill(style.background)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.semibold)
                    .frame(width: size * symbolScale, height: size * symbolScale)
                    .foregroundStyle(style.foreground)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        SymbolTile(systemImage: "person.3.fill")
        SymbolTile(systemImage: "gamecontroller.fill", style: .prominent, size: 44)
        SymbolTile(systemImage: "lock.fill", style: .muted, size: 44)
    }
}
