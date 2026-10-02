import Foundation

extension EcoTip {
    private static let wordsPerMinute = 180
    private static let minimumReadMinutes = 1
    private static let paragraphSeparator = "\n\n"

    var readMinutes: Int {
        let wordCount = body.split(whereSeparator: \.isWhitespace).count
        let minutes = (Double(wordCount) / Double(Self.wordsPerMinute)).rounded(.up)
        return max(Self.minimumReadMinutes, Int(minutes))
    }

    var preview: String {
        let paragraph = body
            .components(separatedBy: Self.paragraphSeparator)
            .first { paragraph in
                guard let block = ArticleBlock.parse(paragraph).first, case .paragraph = block else {
                    return false
                }
                return true
            } ?? body
        guard let attributed = try? AttributedString(markdown: paragraph) else {
            return paragraph
        }
        return String(attributed.characters)
    }

    var coverUrl: URL? {
        return imageUrl.flatMap(URL.init(string:))
    }
}
