final class SignInWithAppleUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(credential: AppleSignInCredential) async throws -> AuthSession {
        return try await authRepository.signInWithApple(credential: credential)
    }
}
