import SwiftUI

struct ShopScreen: View {
    let uiState: ShopUiState
    let onPurchase: (Reward) -> Void
    let onRefresh: () async -> Void

    var body: some View {
        ScrollView {
            if uiState.isLoading {
                StateView(kind: .loading)
                    .containerRelativeFrame(.vertical)
            } else if uiState.hasError {
                StateView(kind: .error(retry: { Task { await onRefresh() } }))
                    .containerRelativeFrame(.vertical)
            } else {
                content
            }
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.shop))
        .refreshable {
            await onRefresh()
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                ProgressHeroCard(points: uiState.points)
                if uiState.hasInsufficientPoints {
                    Text(.shopInsufficientPoints)
                        .font(.footnote)
                        .foregroundStyle(Palette.error)
                }
            }
            SectionTitle(title: .shopCatalogTitle)
            if uiState.rewards.isEmpty {
                emptyText(.shopEmptyRewards)
            } else {
                card {
                    ForEach(uiState.rewards) { reward in
                        rewardRow(reward)
                        if reward.id != uiState.rewards.last?.id {
                            Divider()
                        }
                    }
                }
            }
            SectionTitle(title: .shopHistoryTitle)
            if uiState.purchases.isEmpty {
                emptyText(.shopEmptyPurchases)
            } else {
                card {
                    ForEach(uiState.purchases) { coupon in
                        ListRow(
                            title: uiState.rewardTitle(for: coupon),
                            subtitle: coupon.redeemedAt.formatted(date: .abbreviated, time: .shortened)
                        ) {
                            SymbolTile(systemImage: "gift.fill", color: SectionColor.games)
                        } trailing: {
                            EmptyView()
                        }
                        if coupon.id != uiState.purchases.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.bottom, Spacing.large)
    }

    private func rewardRow(_ reward: Reward) -> some View {
        return HStack(spacing: Spacing.small) {
            VStack(alignment: .leading, spacing: Spacing.hairline) {
                Text(reward.title)
                    .font(.headline)
                Text(reward.partnerName)
                    .font(.subheadline)
                    .foregroundStyle(Palette.secondaryText)
                Text(.shopCostFormat(reward.pointsCost))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.forest)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if uiState.purchasingRewardId == reward.id {
                ProgressView()
            } else {
                Button {
                    onPurchase(reward)
                } label: {
                    Text(.shopPurchaseButton)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .disabled(uiState.purchasingRewardId != nil)
            }
        }
        .padding(.vertical, Spacing.small)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        return VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, Spacing.medium)
        .background(Palette.cardBackground, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
    }

    private func emptyText(_ text: LocalizedStringResource) -> some View {
        return Text(text)
            .font(.subheadline)
            .foregroundStyle(Palette.secondaryText)
    }
}

#Preview {
    NavigationStack {
        ShopScreen(
            uiState: ShopUiState(
                points: 320,
                rewards: [Reward(id: "1", title: "Скидка 10% на кофе", partnerName: "Green Coffee", pointsCost: 150)],
                isLoading: false
            ),
            onPurchase: { _ in },
            onRefresh: {}
        )
    }
}
