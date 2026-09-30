import SwiftUI

enum WasteCategory: CaseIterable {
    case glass
    case metal
    case paper
    case plastic

    var title: LocalizedStringResource {
        switch self {
        case .glass:
            return .sortingBinGlass
        case .metal:
            return .sortingBinMetal
        case .paper:
            return .sortingBinPaper
        case .plastic:
            return .sortingBinPlastic
        }
    }

    var systemImage: String {
        switch self {
        case .glass:
            return "wineglass.fill"
        case .metal:
            return "cylinder.fill"
        case .paper:
            return "newspaper.fill"
        case .plastic:
            return "waterbottle.fill"
        }
    }

    var color: Color {
        switch self {
        case .glass:
            return SectionColor.community
        case .metal:
            return SectionColor.games
        case .paper:
            return SectionColor.calendar
        case .plastic:
            return SectionColor.tips
        }
    }
}
