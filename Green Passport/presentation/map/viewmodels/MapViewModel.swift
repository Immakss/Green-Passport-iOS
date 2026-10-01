import Foundation
import Observation

@Observable
final class MapViewModel {
    @ObservationIgnored private let observeMapPoints: ObserveMapPointsUseCase
    @ObservationIgnored private let savedMapPointIds: SavedMapPointIdsUseCase
    @ObservationIgnored private let toggleSavedMapPoint: ToggleSavedMapPointUseCase

    var uiState = MapUiState()
    private(set) var observationId = 0

    init(
        observeMapPoints: ObserveMapPointsUseCase,
        savedMapPointIds: SavedMapPointIdsUseCase,
        toggleSavedMapPoint: ToggleSavedMapPointUseCase
    ) {
        self.observeMapPoints = observeMapPoints
        self.savedMapPointIds = savedMapPointIds
        self.toggleSavedMapPoint = toggleSavedMapPoint
    }

    func observe() async {
        uiState.savedPointIds = savedMapPointIds.execute()
        do {
            for try await points in observeMapPoints.execute() {
                uiState.points = points
                uiState.isLoading = false
                uiState.hasError = false
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }
            uiState.isLoading = false
            uiState.hasError = uiState.points.isEmpty
        }
    }

    func retry() {
        uiState.isLoading = true
        uiState.hasError = false
        observationId += 1
    }

    func toggleSaved(_ point: MapPoint) {
        let isSaved = !uiState.savedPointIds.contains(point.id)
        toggleSavedMapPoint.execute(pointId: point.id, isSaved: isSaved)
        uiState.savedPointIds = savedMapPointIds.execute()
    }
}
