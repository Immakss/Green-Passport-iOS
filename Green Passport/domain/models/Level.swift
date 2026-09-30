nonisolated struct Level: Hashable, Sendable {
    private static let xpPerLevel = 1000

    let number: Int
    let currentXp: Int
    let xpForNextLevel: Int

    init(lifetimeXp: Int) {
        number = lifetimeXp / Self.xpPerLevel + 1
        currentXp = lifetimeXp % Self.xpPerLevel
        xpForNextLevel = Self.xpPerLevel
    }

    var progress: Double {
        guard xpForNextLevel > 0 else {
            return 0
        }
        return Double(currentXp) / Double(xpForNextLevel)
    }

    var xpLeft: Int {
        return xpForNextLevel - currentXp
    }
}
