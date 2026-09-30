import Foundation

extension EcoTipCategory {
    var title: LocalizedStringResource {
        switch self {
        case .article:
            return .ecotipsCategoryArticle
        case .video:
            return .ecotipsCategoryVideo
        case .kids:
            return .ecotipsCategoryKids
        }
    }

    var systemImage: String {
        switch self {
        case .article:
            return "doc.text.fill"
        case .video:
            return "play.rectangle.fill"
        case .kids:
            return "figure.and.child.holdinghands"
        }
    }
}
