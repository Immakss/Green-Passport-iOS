enum AuthUserAction {
    case emailChanged(String)
    case passwordChanged(String)
    case confirmPasswordChanged(String)
    case submit
    case toggleMode
    case continueWithGoogle
    case continueAnonymously
}
