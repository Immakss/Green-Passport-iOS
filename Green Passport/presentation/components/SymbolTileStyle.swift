import SwiftUI

enum SymbolTileStyle {
    case accent
    case prominent
    case muted
    case tinted(Color)

    var background: AnyShapeStyle {
        switch self {
        case .accent:
            return AnyShapeStyle(Palette.mintSurfaceHigh)
        case .prominent:
            return AnyShapeStyle(Palette.forest.gradient)
        case .muted:
            return AnyShapeStyle(Palette.fieldBackground)
        case .tinted(let color):
            return AnyShapeStyle(color.gradient)
        }
    }

    var foreground: Color {
        switch self {
        case .accent:
            return Palette.forest
        case .prominent:
            return Palette.onForest
        case .muted:
            return Palette.secondaryText
        case .tinted:
            return .white
        }
    }
}
