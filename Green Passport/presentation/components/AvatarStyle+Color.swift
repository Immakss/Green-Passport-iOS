import SwiftUI

extension AvatarStyle {
    var color: Color {
        switch self {
        case .lime:
            return Palette.lime
        case .forest:
            return Palette.forest
        case .sky:
            return SectionColor.calendar
        case .sunset:
            return SectionColor.tips
        case .berry:
            return SectionColor.feedback
        case .violet:
            return SectionColor.games
        }
    }
}
