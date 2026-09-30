import MapKit
import SwiftUI

struct MapScreen: View {
    private static let initialSpan: CLLocationDegrees = 0.25
    private static let annotationSize: CGFloat = 34
    private static let selectedScale: CGFloat = 1.25

    let uiState: MapUiState
    @Binding var searchQuery: String
    @Binding var selectedPointId: String?
    let onFilter: (MapFilter) -> Void
    let onRetry: () -> Void

    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position, selection: $selectedPointId) {
            ForEach(uiState.visiblePoints) { point in
                Annotation(point.name, coordinate: point.coordinate) {
                    SymbolTile(systemImage: point.type.systemImage, style: .prominent, size: Self.annotationSize)
                        .scaleEffect(selectedPointId == point.id ? Self.selectedScale : 1)
                        .shadow(radius: Spacing.xxSmall)
                        .animation(.snappy, value: selectedPointId)
                }
                .tag(point.id)
            }
        }
        .simultaneousGesture(TapGesture().onEnded(Keyboard.dismiss))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .safeAreaInset(edge: .top) {
            controls
        }
        .overlay {
            if uiState.isLoading {
                ProgressView()
                    .controlSize(.large)
            } else if uiState.hasError {
                StateView(kind: .error(retry: onRetry))
                    .background(.regularMaterial)
            }
        }
        .onChange(of: uiState.points) { _, points in
            position = Self.initialPosition(for: points)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var controls: some View {
        VStack(spacing: Spacing.xSmall) {
            HStack(spacing: Spacing.xSmall) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Palette.secondaryText)
                TextField(String(localized: .mapSearchPlaceholder), text: $searchQuery)
                    .submitLabel(.search)
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Palette.secondaryText)
                    }
                    .accessibilityLabel(Text(.close))
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .glassEffect(in: .capsule)
            .padding(.horizontal, Spacing.screenHorizontal)
            FilterBar(options: MapFilter.allFilters, selected: uiState.filter, title: { return $0.title }, onSelect: onFilter)
            if !uiState.isLoading && !uiState.hasError && uiState.visiblePoints.isEmpty {
                Text(.mapEmpty)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.xSmall)
                    .glassEffect(in: .capsule)
            }
        }
    }

    private static func initialPosition(for points: [MapPoint]) -> MapCameraPosition {
        guard !points.isEmpty else {
            return .automatic
        }
        let count = Double(points.count)
        let center = CLLocationCoordinate2D(
            latitude: points.map(\.latitude).reduce(0, +) / count,
            longitude: points.map(\.longitude).reduce(0, +) / count
        )
        let span = MKCoordinateSpan(latitudeDelta: initialSpan, longitudeDelta: initialSpan)
        return .region(MKCoordinateRegion(center: center, span: span))
    }
}

#Preview {
    MapScreen(
        uiState: MapUiState(isLoading: false),
        searchQuery: .constant(""),
        selectedPointId: .constant(nil),
        onFilter: { _ in },
        onRetry: {}
    )
}
