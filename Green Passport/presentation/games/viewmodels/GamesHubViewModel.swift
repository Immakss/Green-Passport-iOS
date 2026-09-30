import Observation

@Observable
final class GamesHubViewModel {
    @ObservationIgnored private let fetchGames: FetchGamesUseCase
    @ObservationIgnored private let fetchBestScores: FetchBestScoresUseCase

    private(set) var uiState: ListUiState<Game> = .loading
    private(set) var bestScores: [String: Int] = [:]

    init(fetchGames: FetchGamesUseCase, fetchBestScores: FetchBestScoresUseCase) {
        self.fetchGames = fetchGames
        self.fetchBestScores = fetchBestScores
    }

    func load() async {
        bestScores = fetchBestScores.execute()
        do {
            uiState = .success(data: try await fetchGames.execute())
        } catch {
            uiState = .error
        }
    }

    func refreshScores() {
        bestScores = fetchBestScores.execute()
    }
}
