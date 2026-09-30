struct MazeUiState {
    var playerPosition = MazeLayout.start
    var collectedItems: Set<MazePosition> = []
    var score = 0
    var isFinished = false
}
