import Observation

@Observable
final class TabRouter {
    var path: [AppDestination] = []

    func push(_ destination: AppDestination) {
        path.append(destination)
    }
}
