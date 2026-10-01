nonisolated struct Wallet: Hashable, Sendable {
    let availablePoints: Int
    let lifetimeXp: Int
    let streak: Streak?

    var level: Level {
        return Level(lifetimeXp: lifetimeXp)
    }
}
