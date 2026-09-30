import MapKit
import SwiftUI

struct MapRoute: View {
    @State private var viewModel: MapViewModel
    @State private var selectedPointId: String?

    init(container: AppDIContainer) {
        _viewModel = State(initialValue: container.buildMapViewModel())
    }

    var body: some View {
        MapScreen(
            uiState: viewModel.uiState,
            searchQuery: $viewModel.uiState.searchQuery,
            selectedPointId: $selectedPointId,
            onFilter: { viewModel.uiState.filter = $0 },
            onRetry: { Task { await viewModel.load() } }
        )
        .task {
            await viewModel.load()
        }
        .sheet(item: selectedPoint) { point in
            MapPointSheet(
                point: point,
                isSaved: viewModel.uiState.savedPointIds.contains(point.id),
                onToggleSaved: { viewModel.toggleSaved(point) },
                onRoute: { openDirections(to: point) }
            )
            .presentationDetents([.height(MapPointSheet.height), .medium])
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .height(MapPointSheet.height)))
        }
    }

    private var selectedPoint: Binding<MapPoint?> {
        return Binding(
            get: { return viewModel.uiState.points.first { $0.id == selectedPointId } },
            set: { selectedPointId = $0?.id }
        )
    }

    private func openDirections(to point: MapPoint) {
        let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
        let item = MKMapItem(location: location, address: nil)
        item.name = point.name
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
}
