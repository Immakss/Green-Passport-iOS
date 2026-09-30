import SwiftUI

struct ListRow<Leading: View, Trailing: View>: View {
    private static var minHeight: CGFloat { return 56 }

    let title: String
    var subtitle: String?
    @ViewBuilder let leading: () -> Leading
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: Spacing.small) {
            leading()
            VStack(alignment: .leading, spacing: Spacing.hairline) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(Palette.secondaryText)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing()
        }
        .frame(minHeight: Self.minHeight)
        .contentShape(.rect)
    }
}

#Preview {
    List {
        ListRow(title: "Сдать батарейки", subtitle: "Минск") {
            MascotImage(size: 34)
        } trailing: {
            PointsBadge(points: 30)
        }
    }
}
