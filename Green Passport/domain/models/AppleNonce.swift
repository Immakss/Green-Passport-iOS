import CryptoKit
import Foundation

nonisolated struct AppleNonce: Sendable {
    private static let length = 32
    private static let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

    let raw: String
    let hashed: String

    init() {
        var generator = SystemRandomNumberGenerator()
        let raw = String((0..<Self.length).map { _ in
            return Self.charset.randomElement(using: &generator) ?? "0"
        })
        let digest = SHA256.hash(data: Data(raw.utf8))
        self.raw = raw
        self.hashed = digest.map { return String(format: "%02x", $0) }.joined()
    }
}
