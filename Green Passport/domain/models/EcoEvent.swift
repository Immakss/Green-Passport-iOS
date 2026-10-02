import Foundation

nonisolated struct EcoEvent: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let location: String
    let city: String
    let startAt: Date
    let imageUrl: String?
    let rewardPoints: Int
    var isActive = true
}
