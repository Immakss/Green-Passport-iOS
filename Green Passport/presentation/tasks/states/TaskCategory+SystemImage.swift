extension TaskCategory {
    var systemImage: String {
        switch self {
        case .recycling:
            return "arrow.3.trianglepath"
        case .cleanup:
            return "leaf.fill"
        case .transport:
            return "bicycle"
        case .reusableItems:
            return "bag.fill"
        case .lecture:
            return "book.fill"
        }
    }
}
