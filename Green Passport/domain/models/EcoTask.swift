nonisolated struct EcoTask: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let category: TaskCategory
    let city: String
    let rewardPoints: Int
    let rewardXp: Int
    let imageUrl: String?
    let verification: TaskVerification
    var isActive = true
}
