import Foundation
import Observation

@Observable
final class GameWebViewModel {
    @ObservationIgnored private let submitGameResult: SubmitGameResultUseCase
    @ObservationIgnored private let gameUrl: GameUrlUseCase

    let game: Game
    var uiState = GameWebUiState()

    init(game: Game, submitGameResult: SubmitGameResultUseCase, gameUrl: GameUrlUseCase) {
        self.game = game
        self.submitGameResult = submitGameResult
        self.gameUrl = gameUrl
    }

    func url(isDark: Bool) -> URL? {
        return gameUrl.execute(game: game, language: AppLanguage.currentCode, isDark: isDark)
    }

    func finish(score: Int) {
        Task {
            guard let reward = await submitGameResult.execute(gameId: game.id, score: score),
                  reward.points > 0 || reward.streakBonus > 0 else {
                return
            }
            uiState.lastReward = reward
            uiState.rewardCount += 1
        }
    }
}
