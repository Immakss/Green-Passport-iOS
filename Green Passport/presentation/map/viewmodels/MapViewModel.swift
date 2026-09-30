import Foundation
import Observation

@Observable
final class MapViewModel {
    @ObservationIgnored private let fetchMapPoints: FetchMapPointsUseCase
    @ObservationIgnored private let savedMapPointIds: SavedMapPointIdsUseCase
    @ObservationIgnored private let toggleSavedMapPoint: ToggleSavedMapPointUseCase

    var uiState = MapUiState()

    init(
        fetchMapPoints: FetchMapPointsUseCase,
        savedMapPointIds: SavedMapPointIdsUseCase,
        toggleSavedMapPoint: ToggleSavedMapPointUseCase
    ) {
        self.fetchMapPoints = fetchMapPoints
        self.savedMapPointIds = savedMapPointIds
        self.toggleSavedMapPoint = toggleSavedMapPoint
    }

    func load() async {
        uiState.savedPointIds = savedMapPointIds.execute()
        uiState.hasError = false
        do {
            uiState.points = try await fetchMapPoints.execute()
        } catch {
            uiState.hasError = true
        }
        uiState.isLoading = false
    }

    func toggleSaved(_ point: MapPoint) {
        let isSaved = !uiState.savedPointIds.contains(point.id)
        toggleSavedMapPoint.execute(pointId: point.id, isSaved: isSaved)
        uiState.savedPointIds = savedMapPointIds.execute()
    }
}
