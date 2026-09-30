enum MazeDirection: CaseIterable {
    case up
    case down
    case left
    case right

    var systemImage: String {
        switch self {
        case .up:
            return "arrow.up"
        case .down:
            return "arrow.down"
        case .left:
            return "arrow.left"
        case .right:
            return "arrow.right"
        }
    }
}
