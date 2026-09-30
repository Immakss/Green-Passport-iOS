import Foundation

struct MapUiState {
    var points: [MapPoint] = []
    var savedPointIds: Set<String> = []
    var filter: MapFilter = .all
    var searchQuery = ""
    var isLoading = true
    var hasError = false

    var visiblePoints: [MapPoint] {
        let query = searchQuery.trimmingCharacters(in: .whitespaces)
        return points.filter { point in
            let matchesType: Bool
            switch filter {
            case .all:
                matchesType = true
            case .type(let type):
                matchesType = point.type == type
            }
            let matchesQuery = query.isEmpty || point.name.localizedCaseInsensitiveContains(query)
            return matchesType && matchesQuery
        }
    }
}
