import Foundation

nonisolated struct AppleSignInCredential: Sendable {
    let idToken: String
    let rawNonce: String
    let fullName: PersonNameComponents?
}
