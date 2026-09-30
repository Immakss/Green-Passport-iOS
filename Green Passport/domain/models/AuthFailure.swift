nonisolated enum AuthFailure: Hashable, Sendable {
    case invalidCredentials
    case invalidEmail
    case emailAlreadyInUse
    case weakPassword
    case network
    case tooManyRequests
    case signInMethodDisabled
    case cancelled
    case googleUnavailable
    case unknown
}
