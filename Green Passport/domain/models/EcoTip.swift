nonisolated struct EcoTip: Identifiable, Hashable, Sendable {
    let id: String
    let category: EcoTipCategory
    let title: String
    let body: String
    var imageUrl: String?
    let mediaUrl: String?
    let isDailyTip: Bool
    let rewardPoints: Int
    let rewardXp: Int
}
