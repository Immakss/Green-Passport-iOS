import AuthenticationServices
import Foundation
import Observation

@Observable
final class AuthViewModel {
    private static let minPasswordLength = 6
    private static let emailPattern = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/

    @ObservationIgnored private let signInWithEmail: SignInWithEmailUseCase
    @ObservationIgnored private let registerWithEmail: RegisterWithEmailUseCase
    @ObservationIgnored private let signInAnonymously: SignInAnonymouslyUseCase
    @ObservationIgnored private let signInWithGoogle: SignInWithGoogleUseCase
    @ObservationIgnored private let signInWithApple: SignInWithAppleUseCase
    @ObservationIgnored private var appleNonce: AppleNonce?

    private(set) var uiState = AuthUiState()

    init(
        signInWithEmail: SignInWithEmailUseCase,
        registerWithEmail: RegisterWithEmailUseCase,
        signInAnonymously: SignInAnonymouslyUseCase,
        signInWithGoogle: SignInWithGoogleUseCase,
        signInWithApple: SignInWithAppleUseCase
    ) {
        self.signInWithEmail = signInWithEmail
        self.registerWithEmail = registerWithEmail
        self.signInAnonymously = signInAnonymously
        self.signInWithGoogle = signInWithGoogle
        self.signInWithApple = signInWithApple
    }

    func handle(_ action: AuthUserAction) {
        switch action {
        case .emailChanged(let value):
            uiState.email = value
            uiState.isEmailInvalid = false
            uiState.failure = nil
        case .passwordChanged(let value):
            uiState.password = value
            uiState.isPasswordTooShort = false
            uiState.isPasswordMismatch = false
            uiState.failure = nil
        case .confirmPasswordChanged(let value):
            uiState.confirmPassword = value
            uiState.isPasswordMismatch = false
            uiState.failure = nil
        case .submit:
            submit()
        case .toggleMode:
            toggleMode()
        case .continueWithGoogle:
            perform { try await self.signInWithGoogle.execute() }
        case .continueAnonymously:
            perform { try await self.signInAnonymously.execute() }
        }
    }

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = AppleNonce()
        appleNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.hashed
    }

    func completeAppleRequest(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = appleCredential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let nonce = appleNonce else {
                uiState.failure = .unknown
                return
            }
            let credential = AppleSignInCredential(
                idToken: idToken,
                rawNonce: nonce.raw,
                fullName: appleCredential.fullName
            )
            perform { try await self.signInWithApple.execute(credential: credential) }
        case .failure(let error):
            if (error as? ASAuthorizationError)?.code != .canceled {
                uiState.failure = .unknown
            }
        }
    }

    private func submit() {
        guard !uiState.isLoading else {
            return
        }
        let email = uiState.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmailInvalid = email.wholeMatch(of: Self.emailPattern) == nil
        let isPasswordTooShort = uiState.password.count < Self.minPasswordLength
        let isPasswordMismatch = uiState.mode == .register && uiState.password != uiState.confirmPassword
        guard !isEmailInvalid, !isPasswordTooShort, !isPasswordMismatch else {
            uiState.isEmailInvalid = isEmailInvalid
            uiState.isPasswordTooShort = isPasswordTooShort
            uiState.isPasswordMismatch = isPasswordMismatch
            return
        }
        let password = uiState.password
        switch uiState.mode {
        case .signIn:
            perform { try await self.signInWithEmail.execute(email: email, password: password) }
        case .register:
            perform { try await self.registerWithEmail.execute(email: email, password: password) }
        }
    }

    private func toggleMode() {
        uiState.mode = uiState.mode == .signIn ? .register : .signIn
        uiState.confirmPassword = ""
        uiState.isEmailInvalid = false
        uiState.isPasswordTooShort = false
        uiState.isPasswordMismatch = false
        uiState.failure = nil
    }

    private func perform(_ action: @escaping () async throws -> AuthSession) {
        guard !uiState.isLoading else {
            return
        }
        uiState.isLoading = true
        uiState.failure = nil
        Task {
            do {
                _ = try await action()
                uiState = AuthUiState()
            } catch {
                let failure = (error as? AuthFailureError)?.failure ?? .unknown
                uiState.isLoading = false
                uiState.failure = failure == .cancelled ? nil : failure
            }
        }
    }
}
