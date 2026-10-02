import SwiftUI

struct StreakSheet: View {
    private static let daySize: CGFloat = 38
    private static let flameScale: CGFloat = 0.45
    private static let todayBorderWidth: CGFloat = 2
    fileprivate static let previewStreakDays = 6
    fileprivate static let previewDaysAgo = -1

    let summary: StreakSummary

    var body: some View {
        VStack(spacing: Spacing.large) {
            Label {
                Text(.streakDaysInRow(summary.days))
            } icon: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Palette.lime)
            }
            .font(.title2.bold())
            weekStrip
            VStack(spacing: Spacing.xSmall) {
                Text(summary.isTodayCounted ? LocalizedStringResource.streakTodayCounted : LocalizedStringResource.streakTodayPending)
                    .font(.headline)
                    .foregroundStyle(summary.isTodayCounted ? Palette.forest : Color.primary)
                Text(summary.daysUntilBonus == 0 ? LocalizedStringResource.streakBonusToday : LocalizedStringResource.streakBonusInDays(summary.daysUntilBonus))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.primary)
            }
            .multilineTextAlignment(.center)
            Text(.streakRule)
                .font(.footnote)
                .foregroundStyle(Palette.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.screenHorizontal)
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.success, trigger: summary.isTodayCounted) { _, isCounted in
            return isCounted
        }
    }

    private var weekStrip: some View {
        return HStack(spacing: Spacing.xSmall) {
            ForEach(summary.week) { day in
                VStack(spacing: Spacing.xxSmall) {
                    Text(day.date, format: .dateTime.weekday(.narrow))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(day.isToday ? Palette.forest : Color.primary)
                    Circle()
                        .fill(day.isActive ? Palette.lime : Palette.mintSurfaceHigh)
                        .frame(width: Self.daySize, height: Self.daySize)
                        .overlay {
                            if day.isActive {
                                Image(systemName: "flame.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Self.daySize * Self.flameScale, height: Self.daySize * Self.flameScale)
                                    .foregroundStyle(Palette.onLime)
                            } else {
                                Text(day.date, format: .dateTime.day())
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Palette.forest)
                            }
                        }
                        .overlay {
                            if day.isToday {
                                Circle()
                                    .strokeBorder(Palette.forest, lineWidth: Self.todayBorderWidth)
                            }
                        }
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
            }
        }
    }
}

#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            StreakSheet(summary: Streak.summary(
                of: Streak(
                    count: StreakSheet.previewStreakDays,
                    lastDay: Streak.dayKey(of: Calendar.minsk.date(byAdding: .day, value: StreakSheet.previewDaysAgo, to: Date()) ?? Date())
                ),
                at: Date()
            ))
                .presentationDetents([.medium])
        }
}
