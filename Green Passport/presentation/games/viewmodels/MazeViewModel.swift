import Observation

@Observable
final class MazeViewModel {
    private static let pointsPerItem = 20

    @ObservationIgnored private let gameSession: GameSession

    private(set) var uiState = MazeUiState()

    init(gameSession: GameSession) {
        self.gameSession = gameSession
    }

    func move(_ direction: MazeDirection) {
        guard !uiState.isFinished else {
            return
        }
        let target = uiState.playerPosition.moved(direction)
        guard let cell = MazeLayout.cell(at: target), cell != .wall else {
            return
        }
        if cell == .item {
            uiState.collectedItems.insert(target)
        }
        uiState.playerPosition = target
        uiState.score = uiState.collectedItems.count * Self.pointsPerItem
        if cell == .exit {
            uiState.isFinished = true
            gameSession.submit(gameId: .ecoMaze, score: uiState.score)
        }
    }

    func restart() {
        uiState = MazeUiState()
    }
}
