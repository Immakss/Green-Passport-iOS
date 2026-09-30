protocol AuthRepository {
    func observeSession() -> AsyncStream<AuthSession?>
    func signInAnonymously() async throws -> AuthSession
    func signIn(email: String, password: String) async throws -> AuthSession
    func register(email: String, password: String) async throws -> AuthSession
    func signInWithGoogle() async throws -> AuthSession
    func signInWithApple(credential: AppleSignInCredential) async throws -> AuthSession
    func signOut() throws
}
