import SwiftUI

struct AchievementsScreen: View {
    private static let tileSize: CGFloat = 44
    private static let lockedOpacity: Double = 0.6

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
                List(achievements) { achievement in
                    HStack(spacing: Spacing.small) {
                        SymbolTile(
                            systemImage: achievement.isUnlocked ? "trophy.fill" : "lock.fill",
                            color: achievement.isUnlocked ? SectionColor.tips : Color(.systemGray3),
                            size: Self.tileSize
                        )
                        VStack(alignment: .leading, spacing: Spacing.hairline) {
                            Text(achievement.id.title)
                                .font(.headline)
                            Text(achievement.id.details)
                                .font(.subheadline)
                                .foregroundStyle(Palette.secondaryText)
                        }
                    }
                    .opacity(achievement.isUnlocked ? 1 : Self.lockedOpacity)
                    .accessibilityElement(children: .combine)
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(Palette.screenBackground)
        .navigationTitle(Text(.achievementsScreenTitle))
    }
}

#Preview {
    NavigationStack {
        AchievementsScreen(
            uiState: .success(data: AchievementId.allCases.map { return Achievement(id: $0, isUnlocked: $0 == .firstTask) }),
            onRetry: {}
        )
    }
}
