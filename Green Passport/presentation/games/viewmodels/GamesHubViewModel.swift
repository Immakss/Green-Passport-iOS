import Observation

@Observable
final class GamesHubViewModel {
    @ObservationIgnored private let fetchBestScores: FetchBestScoresUseCase

    private(set) var bestScores: [GameId: Int] = [:]

    init(fetchBestScores: FetchBestScoresUseCase) {
        self.fetchBestScores = fetchBestScores
    }

    func load() {
        bestScores = fetchBestScores.execute()
    }
}
