import SwiftUI

struct EcoTipsListScreen: View {
    let uiState: EcoTipsListUiState
    let onFilter: (EcoTipFilter) -> Void
    let onTip: (EcoTip) -> Void
    let onToggleBookmark: (EcoTip) -> Void
    let onRefresh: () async -> Void

    var body: some View {
        List {
            if let dailyTip = uiState.dailyTip {
                Section {
                    Button {
                        onTip(dailyTip)
                    } label: {
                        VStack(alignment: .leading, spacing: Spacing.xSmall) {
                            Label {
                                Text(.ecotipsDailyTipLabel)
                            } icon: {
                                Image(systemName: "sun.max.fill")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Palette.forest)
                            Text(dailyTip.title)
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                            Text(dailyTip.body)
                                .font(.subheadline)
                                .foregroundStyle(Palette.secondaryText)
                                .lineLimit(2)
                        }
                        .padding(.vertical, Spacing.xSmall)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Palette.mintSurface)
                }
            }
            Section {
                FilterBar(options: EcoTipFilter.allFilters, selected: uiState.filter, title: { return $0.title }, onSelect: onFilter)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            .listSectionMargins(.horizontal, 0)
            if !uiState.visibleTips.isEmpty {
                Section {
                    ForEach(uiState.visibleTips) { tip in
                        row(tip)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if uiState.isLoading {
                StateView(kind: .loading)
            } else if uiState.hasError {
                StateView(kind: .error(retry: { Task { await onRefresh() } }))
            } else if uiState.visibleTips.isEmpty {
                StateView(kind: .empty(message: .ecotipsEmpty))
            }
        }
        .navigationTitle(Text(.homeTileEcotips))
        .refreshable {
            await onRefresh()
        }
    }

    private func row(_ tip: EcoTip) -> some View {
        let isRead = uiState.readTipIds.contains(tip.id)
        let isBookmarked = uiState.bookmarkedTipIds.contains(tip.id)
        return Button {
            onTip(tip)
        } label: {
            ListRow(title: tip.title, subtitle: String(localized: tip.category.title)) {
                SymbolTile(
                    systemImage: isRead ? "checkmark" : "leaf.fill",
                    color: isRead ? SectionColor.community : SectionColor.tips
                )
            } trailing: {
                Button {
                    onToggleBookmark(tip)
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(isBookmarked ? Palette.forest : Palette.secondaryText)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(Text(.profileBookmarks))
                .sensoryFeedback(.impact, trigger: isBookmarked)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        EcoTipsListScreen(
            uiState: EcoTipsListUiState(
                tips: [EcoTip(id: "1", category: .article, title: "Как сортировать пластик", body: "Смотрите на маркировку", mediaUrl: nil, isDailyTip: true, rewardPoints: 10, rewardXp: 20)],
                isLoading: false
            ),
            onFilter: { _ in },
            onTip: { _ in },
            onToggleBookmark: { _ in },
            onRefresh: {}
        )
    }
}
