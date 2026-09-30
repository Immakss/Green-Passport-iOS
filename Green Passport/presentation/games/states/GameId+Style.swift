import Foundation

extension GameId {
    var title: LocalizedStringResource {
        switch self {
        case .ecoPuzzle:
            return .gameEcoPuzzleTitle
        case .wasteSorting:
            return .gameWasteSortingTitle
        case .ecoMaze:
            return .gameEcoMazeTitle
        case .ecoQuiz:
            return .gameEcoQuizTitle
        }
    }

    var systemImage: String {
        switch self {
        case .ecoPuzzle:
            return "puzzlepiece.extension.fill"
        case .wasteSorting:
            return "trash.fill"
        case .ecoMaze:
            return "safari.fill"
        case .ecoQuiz:
            return "questionmark.bubble.fill"
        }
    }

}
