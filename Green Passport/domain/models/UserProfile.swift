nonisolated struct UserProfile: Hashable, Sendable {
    let userId: String
    let firstName: String
    let lastName: String
    let city: String
    let interests: Set<TaskCategory>
    let avatar: AvatarStyle
}
