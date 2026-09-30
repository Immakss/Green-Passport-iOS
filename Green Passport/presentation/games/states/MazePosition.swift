struct MazePosition: Hashable {
    let row: Int
    let column: Int

    func moved(_ direction: MazeDirection) -> MazePosition {
        switch direction {
        case .up:
            return MazePosition(row: row - 1, column: column)
        case .down:
            return MazePosition(row: row + 1, column: column)
        case .left:
            return MazePosition(row: row, column: column - 1)
        case .right:
            return MazePosition(row: row, column: column + 1)
        }
    }
}
