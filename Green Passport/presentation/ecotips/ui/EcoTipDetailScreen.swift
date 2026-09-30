import SwiftUI

struct EcoTipDetailScreen: View {
    let uiState: EcoTipDetailUiState
    let onMarkRead: () -> Void
    let onRetry: () -> Void

    var body: some View {
        Group {
            if uiState.hasError {
                StateView(kind: .error(retry: onRetry))
            } else if let tip = uiState.tip, !uiState.isLoading {
                content(tip: tip)
            } else {
                StateView(kind: .loading)
            }
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.ecotipDetailTitle))
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: uiState.isRead) { _, isRead in
            return isRead
        }
    }

    private func content(tip: EcoTip) -> some View {
        return ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Label {
                    Text(tip.category.title)
                } icon: {
                    Image(systemName: tip.category.systemImage)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SectionColor.tips)
                Text(tip.title)
                    .font(.largeTitle.bold())
                Text(tip.body)
                    .font(.body)
                if let mediaUrl = tip.mediaUrl, let url = URL(string: mediaUrl) {
                    Link(destination: url) {
                        Label {
                            Text(mediaUrl)
                                .lineLimit(1)
                        } icon: {
                            Image(systemName: tip.category == .video ? "play.circle.fill" : "link")
                        }
                    }
                    .font(.subheadline.weight(.medium))
                }
                Text(.ecotipDetailRewardFormat(tip.rewardPoints, tip.rewardXp))
                    .font(.subheadline)
                    .foregroundStyle(Palette.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.screenHorizontal)
        }
        .safeAreaInset(edge: .bottom) {
            Group {
                if uiState.isRead {
                    Label {
                        Text(.ecotipDetailReadLabel)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .font(.headline)
                    .foregroundStyle(Palette.forest)
                } else {
                    AppButton(title: .ecotipDetailMarkReadButton, isLoading: uiState.isSubmitting, action: onMarkRead)
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.medium)
        }
    }
}

#Preview {
    NavigationStack {
        EcoTipDetailScreen(
            uiState: EcoTipDetailUiState(
                tip: EcoTip(id: "1", category: .video, title: "Как сортировать пластик", body: "Смотрите на маркировку на упаковке.", mediaUrl: "https://example.com", isDailyTip: false, rewardPoints: 10, rewardXp: 20),
                isLoading: false
            ),
            onMarkRead: {},
            onRetry: {}
        )
    }
}
