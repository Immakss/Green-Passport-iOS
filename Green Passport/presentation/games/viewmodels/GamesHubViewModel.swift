import Observation

@Observable
final class GamesHubViewModel {
    @ObservationIgnored private let observeGames: ObserveGamesUseCase
    @ObservationIgnored private let fetchBestScores: FetchBestScoresUseCase

    private(set) var uiState: ListUiState<Game> = .loading
    private(set) var bestScores: [String: Int] = [:]
    private(set) var observationId = 0

    init(observeGames: ObserveGamesUseCase, fetchBestScores: FetchBestScoresUseCase) {
        self.observeGames = observeGames
        self.fetchBestScores = fetchBestScores
    }

    func observe() async {
        bestScores = fetchBestScores.execute()
        do {
            for try await games in observeGames.execute() {
                uiState = .success(data: games)
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }
            uiState = .error
        }
    }

    func retry() {
        uiState = .loading
        observationId += 1
    }

    func refreshScores() {
        bestScores = fetchBestScores.execute()
    }
}
