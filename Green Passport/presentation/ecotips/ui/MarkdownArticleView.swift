import SwiftUI

struct MarkdownArticleView: View {
    let markdown: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            ForEach(Array(ArticleBlock.parse(markdown).enumerated()), id: \.offset) { _, block in
                switch block {
                case .heading:
                    Text(block.inlineText)
                        .font(.title3.bold())
                        .padding(.top, Spacing.xSmall)
                case .paragraph:
                    Text(block.inlineText)
                        .font(.body)
                case .bullet:
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xSmall) {
                        Image(systemName: "circle.fill")
                            .font(.system(.caption2))
                            .imageScale(.small)
                            .foregroundStyle(Palette.forest)
                        Text(block.inlineText)
                            .font(.body)
                    }
                }
            }
        }
        .tint(Palette.forest)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ScrollView {
        MarkdownArticleView(markdown: "Первый абзац с **жирным** текстом.\n\n## Подзаголовок\n\n- Пункт один\n- Пункт два\n\nПоследний абзац.")
            .padding()
    }
}
