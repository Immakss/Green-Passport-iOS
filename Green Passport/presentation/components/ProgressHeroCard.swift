import SwiftUI

struct ProgressHeroCard: View {
    private static let minHeight: CGFloat = 140
    private static let mascotSize: CGFloat = 96
    private static let barHeight: CGFloat = 8
    private static let trackOpacity: Double = 0.22
    private static let captionOpacity: Double = 0.8
    private static let bubbleMaxWidth: CGFloat = 132

    let points: Int
    var level: Level?
    var streakDays = 0

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.small) {
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                HStack(spacing: Spacing.xSmall) {
                    Text(level.map { return .level($0.number) } ?? .yourBalance)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Palette.onForest.opacity(Self.captionOpacity))
                    if streakDays > 0 {
                        Label {
                            Text(.streakDays(streakDays))
                        } icon: {
                            Image(systemName: "flame.fill")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Palette.onLime)
                        .padding(.horizontal, Spacing.xSmall)
                        .padding(.vertical, Spacing.hairline)
                        .background(Palette.lime, in: .capsule)
                    }
                }
                Label {
                    Text(.pointsCount(points))
                        .contentTransition(.numericText(value: Double(points)))
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Palette.lime)
                }
                .font(.title.bold())
                .foregroundStyle(Palette.onForest)
                if let level {
                    progressBar(level: level)
                        .padding(.top, Spacing.small)
                    Text(.xpProgress(level.currentXp, level.xpForNextLevel))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Palette.onForest.opacity(Self.captionOpacity))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: Spacing.xxSmall) {
                if let level {
                    Text(.xpLeftToLevel(level.xpLeft, level.number + 1))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xSmall)
                        .padding(.vertical, Spacing.xxSmall)
                        .background(Palette.cardBackground, in: .rect(cornerRadius: CornerRadius.small))
                        .frame(maxWidth: Self.bubbleMaxWidth)
                }
                MascotImage(size: Self.mascotSize)
            }
        }
        .padding(Spacing.medium)
        .padding(.leading, Spacing.xSmall)
        .frame(maxWidth: .infinity, minHeight: Self.minHeight)
        .background(Palette.forest.gradient, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func progressBar(level: Level) -> some View {
        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Palette.onForest.opacity(Self.trackOpacity))
                Capsule()
                    .fill(Palette.lime)
                    .frame(width: proxy.size.width * level.progress)
            }
        }
        .frame(height: Self.barHeight)
    }
}

#Preview {
    VStack {
        ProgressHeroCard(points: 500, level: Level(lifetimeXp: 2800), streakDays: 5)
        ProgressHeroCard(points: 120)
    }
    .padding()
}
