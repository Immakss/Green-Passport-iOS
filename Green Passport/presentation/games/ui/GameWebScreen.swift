import SwiftUI

struct GameWebScreen: View {
    private static let bannerVisibleDuration = Duration.seconds(2)

    let title: String
    let url: URL?
    let uiState: GameWebUiState
    let reloadId: Int
    let onMessage: (GameBridgeMessage) -> Void
    let onLoadingChange: (Bool) -> Void
    let onFailure: () -> Void
    let onRetry: () -> Void

    @State private var isBannerVisible = false

    var body: some View {
        ZStack {
            Palette.screenBackground
                .ignoresSafeArea()
            if let url, !uiState.hasError {
                GameWebView(url: url, onMessage: onMessage, onLoadingChange: onLoadingChange, onFailure: onFailure)
                    .id(reloadId)
                    .ignoresSafeArea(edges: .bottom)
            }
            if uiState.hasError || url == nil {
                StateView(kind: .error(retry: onRetry))
            } else if uiState.isLoading {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .overlay(alignment: .top) {
            if isBannerVisible, let reward = uiState.lastReward {
                HStack(spacing: Spacing.xSmall) {
                    PointsBadge(points: reward.points)
                    if reward.streakBonus > 0 {
                        Text(.streakBonusMsg(reward.streakBonus))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Palette.forest)
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.xSmall)
                .glassEffect(in: .capsule)
                .padding(.top, Spacing.xSmall)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: isBannerVisible)
        .navigationTitle(title)
        .sensoryFeedback(.success, trigger: uiState.rewardCount)
        .task(id: uiState.rewardCount) {
            guard uiState.rewardCount > 0 else {
                return
            }
            isBannerVisible = true
            try? await Task.sleep(for: Self.bannerVisibleDuration)
            isBannerVisible = false
        }
    }
}
