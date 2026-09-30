struct AuthUiState {
    var mode: AuthMode = .signIn
    var email = ""
    var password = ""
    var confirmPassword = ""
    var isLoading = false
    var isEmailInvalid = false
    var isPasswordTooShort = false
    var isPasswordMismatch = false
    var failure: AuthFailure?
}
