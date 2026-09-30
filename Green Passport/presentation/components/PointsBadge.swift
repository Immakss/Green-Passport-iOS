import SwiftUI

struct PointsBadge: View {
    let points: Int

    var body: some View {
        Label {
            Text(.pointsReward(points))
        } icon: {
            Image(systemName: "bolt.fill")
        }
        .labelStyle(.titleAndIcon)
        .font(.footnote.weight(.semibold))
        .foregroundStyle(Palette.onLime)
        .padding(.horizontal, Spacing.xSmall)
        .padding(.vertical, Spacing.xxSmall)
        .background(Palette.lime, in: .capsule)
    }
}

#Preview {
    PointsBadge(points: 50)
}
