import SwiftUI

struct GamesHubRoute: View {
    @Environment(TabRouter.self) private var router
    @State private var viewModel: GamesHubViewModel

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildGamesHubViewModel())
    }

    var body: some View {
        GamesHubScreen(bestScores: viewModel.bestScores) { game in
            router.push(.game(game))
        }
        .onAppear(perform: viewModel.load)
    }
}
