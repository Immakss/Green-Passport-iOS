nonisolated struct Achievement: Identifiable, Hashable, Sendable {
    let id: AchievementId
    let progress: Int
    let target: Int

    var isUnlocked: Bool {
        return progress >= target
    }

    var clampedProgress: Int {
        return min(progress, target)
    }
}
