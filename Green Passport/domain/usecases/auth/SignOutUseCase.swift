final class SignOutUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() throws {
        try authRepository.signOut()
    }
}
