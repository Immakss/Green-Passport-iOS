import Foundation

final class WordListTextModerator: TextModerator {
    private static let bannedRootsResource = "banned_roots"
    private static let allowedStemsResource = "allowed_words"
    private static let wordSeparator = /[^a-zа-я]+/
    private static let cyrillicLookalikes: [Character: Character] = [
        "a": "а", "e": "е", "o": "о", "p": "р", "c": "с", "x": "х", "y": "у",
        "k": "к", "m": "м", "h": "н", "b": "в", "t": "т", "u": "и", "n": "п",
        "0": "о", "3": "з", "6": "б", "@": "а",
    ]
    private static let latinLookalikes: [Character: Character] = [
        "а": "a", "е": "e", "о": "o", "р": "p", "с": "c", "х": "x", "у": "y",
        "к": "k", "м": "m", "т": "t", "0": "o", "1": "i", "3": "e", "4": "a",
        "@": "a", "$": "s",
    ]

    private lazy var bannedRoots = Self.readLines(resource: Self.bannedRootsResource)
    private lazy var allowedStems = Self.readLines(resource: Self.allowedStemsResource)

    func isAllowed(_ text: String) -> Bool {
        let lowercase = text.lowercased().replacingOccurrences(of: "ё", with: "е")
        let candidates = words(in: map(lowercase, with: Self.cyrillicLookalikes))
            + words(in: map(lowercase, with: Self.latinLookalikes))
        return !candidates.contains { return isBanned($0) }
    }

    private func isBanned(_ word: String) -> Bool {
        let hasAllowedStem = allowedStems.contains { return word.contains($0) }
        let hasBannedRoot = bannedRoots.contains { return word.contains($0) }
        return !hasAllowedStem && hasBannedRoot
    }

    private func words(in text: String) -> [String] {
        let tokens = text.split(separator: Self.wordSeparator).map(String.init).filter { return !$0.isEmpty }
        var merged: [String] = []
        var singleLetters = ""
        for token in tokens {
            if token.count == 1 {
                singleLetters += token
            } else {
                if !singleLetters.isEmpty {
                    merged.append(singleLetters)
                }
                singleLetters = ""
                merged.append(token)
            }
        }
        if !singleLetters.isEmpty {
            merged.append(singleLetters)
        }
        return merged.map { return collapseRepeatedLetters($0) }
    }

    private func collapseRepeatedLetters(_ word: String) -> String {
        var result = ""
        for character in word where character != result.last {
            result.append(character)
        }
        return result
    }

    private func map(_ text: String, with lookalikes: [Character: Character]) -> String {
        return String(text.map { return lookalikes[$0] ?? $0 })
    }

    private static func readLines(resource: String) -> [String] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return content
            .split(whereSeparator: \.isNewline)
            .map { return $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { return !$0.isEmpty }
    }
}
