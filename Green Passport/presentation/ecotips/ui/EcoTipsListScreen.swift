import SwiftUI

struct EcoTipsListScreen: View {
    let uiState: EcoTipsListUiState
    let onFilter: (EcoTipFilter) -> Void
    let onTip: (EcoTip) -> Void
    let onToggleBookmark: (EcoTip) -> Void
    let onRetry: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                if let dailyTip = uiState.dailyTip {
                    dailyTipCard(dailyTip)
                        .padding(.horizontal, Spacing.screenHorizontal)
                }
                FilterBar(options: EcoTipFilter.allFilters, selected: uiState.filter, title: { return $0.title }, onSelect: onFilter)
                content
            }
            .padding(.top, Spacing.xSmall)
            .padding(.bottom, Spacing.large)
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.homeTileEcotips))
    }

    @ViewBuilder
    private var content: some View {
        if uiState.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.xLarge)
        } else if uiState.hasError {
            StateView(kind: .error(retry: onRetry))
        } else if uiState.visibleTips.isEmpty {
            StateView(kind: .empty(message: .ecotipsEmpty))
        } else {
            VStack(spacing: Spacing.small) {
                ForEach(uiState.visibleTips) { tip in
                    row(tip)
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
        }
    }

    private func dailyTipCard(_ tip: EcoTip) -> some View {
        return Button {
            onTip(tip)
        } label: {
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Label {
                    Text(.ecotipsDailyTipLabel)
                } icon: {
                    Image(systemName: "sun.max.fill")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Palette.forest)
                Text(tip.title)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Text(tip.body)
                    .font(.subheadline)
                    .foregroundStyle(Palette.secondaryText)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.medium)
            .background(Palette.mintSurface, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func row(_ tip: EcoTip) -> some View {
        let isRead = uiState.readTipIds.contains(tip.id)
        let isBookmarked = uiState.bookmarkedTipIds.contains(tip.id)
        return Button {
            onTip(tip)
        } label: {
            ListRow(title: tip.title, subtitle: String(localized: tip.category.title)) {
                SymbolTile(systemImage: isRead ? "checkmark" : "leaf.fill", style: isRead ? .prominent : .accent)
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
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.xSmall)
            .background(Palette.cardBackground, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
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
            onRetry: {}
        )
    }
}
