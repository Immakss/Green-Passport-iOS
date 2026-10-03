import SwiftUI

struct FavoritesScreen: View {
    private static let mascotSize: CGFloat = 34

    let uiState: FavoritesUiState
    @Binding var segment: FavoritesSegment
    let onTask: (EcoTask) -> Void
    let onTip: (EcoTip) -> Void
    let onPlace: (MapPoint) -> Void
    let onRetry: () -> Void

    var body: some View {
        List {
            switch segment {
            case .tasks:
                ForEach(uiState.favoriteTasks) { task in
                    Button {
                        onTask(task)
                    } label: {
                        ListRow(title: task.title, subtitle: String(localized: task.category.title)) {
                            MascotImage(size: Self.mascotSize)
                        } trailing: {
                            PointsBadge(points: task.rewardPoints)
                        }
                    }
                    .buttonStyle(.plain)
                }
            case .tips:
                ForEach(uiState.bookmarkedTips) { tip in
                    Button {
                        onTip(tip)
                    } label: {
                        ListRow(title: tip.title, subtitle: String(localized: tip.category.title)) {
                            SymbolTile(systemImage: tip.category.systemImage)
                        } trailing: {
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                    }
                    .buttonStyle(.plain)
                }
            case .places:
                ForEach(uiState.savedPlaces) { point in
                    Button {
                        onPlace(point)
                    } label: {
                        ListRow(title: point.name, subtitle: String(localized: point.type.title)) {
                            SymbolTile(systemImage: point.type.systemImage)
                        } trailing: {
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .top) {
            Picker(selection: $segment) {
                ForEach(FavoritesSegment.allCases, id: \.self) { option in
                    Text(option.title).tag(option)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.xSmall)
        }
        .overlay {
            overlayState
        }
        .navigationTitle(Text(.favoritesScreenTitle))
    }

    @ViewBuilder
    private var overlayState: some View {
        if uiState.isLoading {
            StateView(kind: .loading)
        } else if uiState.hasError {
            StateView(kind: .error(retry: onRetry))
        } else if segment == .tasks && uiState.favoriteTasks.isEmpty {
            StateView(kind: .empty(message: .favoritesEmpty))
        } else if segment == .tips && uiState.bookmarkedTips.isEmpty {
            StateView(kind: .empty(message: .bookmarksEmpty))
        } else if segment == .places && uiState.savedPlaces.isEmpty {
            StateView(kind: .empty(message: .savedPlacesEmpty))
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesScreen(
            uiState: FavoritesUiState(isLoading: false),
            segment: .constant(.tasks),
            onTask: { _ in },
            onTip: { _ in },
            onPlace: { _ in },
            onRetry: {}
        )
    }
}
