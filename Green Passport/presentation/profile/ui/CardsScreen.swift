import SwiftUI

struct CardsScreen: View {
    private static let columnCount = 2
    private static let symbolSize: CGFloat = 44

    let uiState: ListUiState<Achievement>
    let onRetry: () -> Void

    var body: some View {
        Group {
            switch uiState {
            case .loading:
                StateView(kind: .loading)
            case .error:
                StateView(kind: .error(retry: onRetry))
            case .success(let achievements):
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.small), count: Self.columnCount),
                        spacing: Spacing.small
                    ) {
                        ForEach(achievements) { achievement in
                            card(achievement)
                        }
                    }
                    .padding(Spacing.screenHorizontal)
                }
            }
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.cardsScreenTitle))
    }

    private func card(_ achievement: Achievement) -> some View {
        return VStack(spacing: Spacing.small) {
            Image(systemName: achievement.isUnlocked ? "trophy.fill" : "lock.fill")
                .font(.system(size: Self.symbolSize))
                .foregroundStyle(achievement.isUnlocked ? Palette.forest : Palette.secondaryText)
            Text(achievement.isUnlocked ? achievement.id.title : .cardsLockedLabel)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(achievement.isUnlocked ? Color.primary : Palette.secondaryText)
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(
            achievement.isUnlocked ? Palette.mintSurface : Palette.cardBackground,
            in: .rect(cornerRadius: CornerRadius.large, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        CardsScreen(
            uiState: .success(data: AchievementId.allCases.map { return Achievement(id: $0, isUnlocked: $0 == .firstTask) }),
            onRetry: {}
        )
    }
}
