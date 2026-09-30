final class RegisterWithEmailUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String) async throws -> AuthSession {
        return try await authRepository.register(email: email, password: password)
    }
}
