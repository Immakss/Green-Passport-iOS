nonisolated struct Reward: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let partnerName: String
    let pointsCost: Int
    var imageUrl: String?
    var isActive = true
}
