import SwiftUI

enum SymbolTileStyle {
    case accent
    case prominent
    case muted

    var background: AnyShapeStyle {
        switch self {
        case .accent:
            return AnyShapeStyle(Palette.mintSurface)
        case .prominent:
            return AnyShapeStyle(Palette.forest.gradient)
        case .muted:
            return AnyShapeStyle(Palette.fieldBackground)
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
        }
    }
}
