nonisolated struct FeedbackEntry: Hashable, Sendable {
    let userId: String
    let type: FeedbackType
    let message: String
    let rating: Int?
}
