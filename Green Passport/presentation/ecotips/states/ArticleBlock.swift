import Foundation

nonisolated enum ArticleBlock: Hashable, Sendable {
    case heading(String)
    case paragraph(String)
    case bullet(String)

    private static let headingPrefix = "## "
    private static let bulletPrefix = "- "

    static func parse(_ markdown: String) -> [ArticleBlock] {
        return markdown.components(separatedBy: .newlines)
            .map { return $0.trimmingCharacters(in: .whitespaces) }
            .filter { return !$0.isEmpty }
            .map { line in
                if line.hasPrefix(headingPrefix) {
                    return .heading(String(line.dropFirst(headingPrefix.count)))
                }
                if line.hasPrefix(bulletPrefix) {
                    return .bullet(String(line.dropFirst(bulletPrefix.count)))
                }
                return .paragraph(line)
            }
    }

    var text: String {
        switch self {
        case .heading(let text), .paragraph(let text), .bullet(let text):
            return text
        }
    }

    var inlineText: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    }
}
