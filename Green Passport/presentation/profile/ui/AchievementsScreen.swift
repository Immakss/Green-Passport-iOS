import SwiftUI

struct AchievementsScreen: View {
    private static let columnCount = 2
    private static let tileSize: CGFloat = 44
    private static let cardMinHeight: CGFloat = 196

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
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text(.achievementsUnlockedFormat(achievements.filter(\.isUnlocked).count, achievements.count))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Palette.secondaryText)
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.small), count: Self.columnCount),
                            spacing: Spacing.small
                        ) {
                            ForEach(achievements) { achievement in
                                card(achievement)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)
                    .padding(.bottom, Spacing.large)
                }
            }
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.achievementsScreenTitle))
    }

    private func card(_ achievement: Achievement) -> some View {
        return VStack(alignment: .leading, spacing: Spacing.xSmall) {
            SymbolTile(
                systemImage: achievement.id.systemImage,
                style: achievement.isUnlocked ? .prominent : .muted,
                size: Self.tileSize
            )
            Text(achievement.id.title)
                .font(.headline)
                .foregroundStyle(achievement.isUnlocked ? Color.primary : Palette.secondaryText)
            Text(achievement.id.details)
                .font(.footnote)
                .foregroundStyle(Palette.secondaryText)
            Spacer(minLength: 0)
            if achievement.isUnlocked {
                Label {
                    Text(.achievementUnlockedLabel)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Palette.forest)
            } else {
                ProgressView(value: Double(achievement.clampedProgress), total: Double(achievement.target))
                    .tint(Palette.forest)
                Text(.achievementProgressFormat(achievement.clampedProgress, achievement.target))
                    .font(.caption)
                    .foregroundStyle(Palette.secondaryText)
            }
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, minHeight: Self.cardMinHeight, alignment: .topLeading)
        .background(
            achievement.isUnlocked ? Palette.mintSurface : Palette.cardBackground,
            in: .rect(cornerRadius: CornerRadius.large, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        AchievementsScreen(
            uiState: .success(data: [
                Achievement(id: .firstTask, progress: 1, target: 1),
                Achievement(id: .taskMaster, progress: 2, target: 5),
                Achievement(id: .eventGoer, progress: 0, target: 1),
                Achievement(id: .ecoReader, progress: 3, target: 3),
                Achievement(id: .communityMember, progress: 0, target: 1),
                Achievement(id: .levelFive, progress: 2, target: 5),
            ]),
            onRetry: {}
        )
    }
}
