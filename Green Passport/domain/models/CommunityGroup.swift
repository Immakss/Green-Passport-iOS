nonisolated struct CommunityGroup: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let memberIds: [String]
}
