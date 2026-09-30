final class ObserveSessionUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() -> AsyncStream<AuthSession?> {
        return authRepository.observeSession()
    }

    func current() async -> AuthSession? {
        for await session in authRepository.observeSession() {
            return session
        }
        return nil
    }
}
