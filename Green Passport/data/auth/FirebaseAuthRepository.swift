import FirebaseAuth
import Foundation

final class FirebaseAuthRepository: AuthRepository {
    private static let googleProviderId = "google.com"
    private static let configurationNotFoundMarker = "CONFIGURATION_NOT_FOUND"

    private let auth: Auth
    private let googleSignInProvider: GoogleSignInProvider

    init(auth: Auth, googleSignInProvider: GoogleSignInProvider) {
        self.auth = auth
        self.googleSignInProvider = googleSignInProvider
    }

    func observeSession() -> AsyncStream<AuthSession?> {
        let auth = auth
        return AsyncStream { continuation in
            let handle = auth.addStateDidChangeListener { _, user in
                continuation.yield(user.map(Self.session(from:)))
            }
            continuation.onTermination = { _ in
                auth.removeStateDidChangeListener(handle)
            }
        }
    }

    func signInAnonymously() async throws -> AuthSession {
        return try await perform { try await auth.signInAnonymously() }
    }

    func signIn(email: String, password: String) async throws -> AuthSession {
        return try await perform { try await auth.signIn(withEmail: email, password: password) }
    }

    func register(email: String, password: String) async throws -> AuthSession {
        return try await perform { try await auth.createUser(withEmail: email, password: password) }
    }

    func signInWithGoogle() async throws -> AuthSession {
        let tokens = try await googleSignInProvider.requestTokens()
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await perform { try await auth.signIn(with: credential) }
    }

    func signInWithApple(credential: AppleSignInCredential) async throws -> AuthSession {
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: credential.idToken,
            rawNonce: credential.rawNonce,
            fullName: credential.fullName
        )
        return try await perform { try await auth.signIn(with: firebaseCredential) }
    }

    func signOut() throws {
        googleSignInProvider.signOut()
        try auth.signOut()
    }

    private func perform(_ action: () async throws -> AuthDataResult) async throws -> AuthSession {
        do {
            let result = try await action()
            return Self.session(from: result.user)
        } catch {
            throw AuthFailureError(failure: Self.failure(from: error))
        }
    }

    private static func session(from user: User) -> AuthSession {
        let displayName = user.displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
        return AuthSession(
            userId: user.uid,
            email: user.email,
            isAnonymous: user.isAnonymous,
            displayName: displayName?.isEmpty == false ? displayName : nil,
            isGoogleAccount: user.providerData.contains { $0.providerID == googleProviderId }
        )
    }

    private static func failure(from error: Error) -> AuthFailure {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown
        }
        switch code {
        case .networkError:
            return .network
        case .tooManyRequests:
            return .tooManyRequests
        case .weakPassword:
            return .weakPassword
        case .emailAlreadyInUse, .credentialAlreadyInUse:
            return .emailAlreadyInUse
        case .userNotFound, .wrongPassword, .invalidCredential, .userDisabled:
            return .invalidCredentials
        case .invalidEmail:
            return .invalidEmail
        case .operationNotAllowed:
            return .signInMethodDisabled
        default:
            if nsError.localizedDescription.contains(configurationNotFoundMarker) {
                return .signInMethodDisabled
            }
            return .unknown
        }
    }
}
