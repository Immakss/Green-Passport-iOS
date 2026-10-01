import Foundation
import Observation

@Observable
final class MapViewModel {
    @ObservationIgnored private let observeMapPoints: ObserveMapPointsUseCase
    @ObservationIgnored private let savedMapPointIds: SavedMapPointIdsUseCase
    @ObservationIgnored private let toggleSavedMapPoint: ToggleSavedMapPointUseCase
    @ObservationIgnored private let resolveMapFocus: ResolveMapFocusUseCase

    var uiState = MapUiState()
    private(set) var observationId = 0

    init(
        observeMapPoints: ObserveMapPointsUseCase,
        savedMapPointIds: SavedMapPointIdsUseCase,
        toggleSavedMapPoint: ToggleSavedMapPointUseCase,
        resolveMapFocus: ResolveMapFocusUseCase
    ) {
        self.observeMapPoints = observeMapPoints
        self.savedMapPointIds = savedMapPointIds
        self.toggleSavedMapPoint = toggleSavedMapPoint
        self.resolveMapFocus = resolveMapFocus
    }

    func observe() async {
        uiState.savedPointIds = savedMapPointIds.execute()
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.resolveFocus() }
            group.addTask { await self.observePoints() }
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

    private func resolveFocus() async {
        guard uiState.focus == nil else {
            return
        }
        uiState.focus = await resolveMapFocus.execute()
    }

    private func observePoints() async {
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
}
