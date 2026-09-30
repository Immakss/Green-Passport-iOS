final class SignInWithGoogleUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() async throws -> AuthSession {
        return try await authRepository.signInWithGoogle()
    }
}
