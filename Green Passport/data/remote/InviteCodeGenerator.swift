enum InviteCodeGenerator {
    static let length = 6

    private static let alphabet = Array("ABCDEFGHJKMNPQRSTUVWXYZ23456789")

    static func generate() -> String {
        var generator = SystemRandomNumberGenerator()
        return String((0..<length).compactMap { _ in return alphabet.randomElement(using: &generator) })
    }
}
