enum MazeLayout {
    private static let rows = [
        "S....",
        "###.#",
        ".....",
        ".#I#.",
        ".I..E",
    ]

    static let grid: [[MazeCell]] = rows.map { row in
        return row.map { character in
            switch character {
            case "#":
                return .wall
            case "I":
                return .item
            case "S":
                return .start
            case "E":
                return .exit
            default:
                return .path
            }
        }
    }

    static let start: MazePosition = {
        for (rowIndex, row) in grid.enumerated() {
            if let columnIndex = row.firstIndex(of: .start) {
                return MazePosition(row: rowIndex, column: columnIndex)
            }
        }
        return MazePosition(row: 0, column: 0)
    }()

    static func cell(at position: MazePosition) -> MazeCell? {
        guard grid.indices.contains(position.row), grid[position.row].indices.contains(position.column) else {
            return nil
        }
        return grid[position.row][position.column]
    }
}
