final class SignInWithEmailUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String) async throws -> AuthSession {
        return try await authRepository.signIn(email: email, password: password)
    }
}
