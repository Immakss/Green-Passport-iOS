nonisolated struct AuthSession: Hashable, Sendable {
    let userId: String
    let email: String?
    let isAnonymous: Bool
    let displayName: String?
    let isGoogleAccount: Bool
}
