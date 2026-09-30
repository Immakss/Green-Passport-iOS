import SwiftUI

struct ChoiceCapsule: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.xSmall + Spacing.xxSmall)
                .foregroundStyle(isSelected ? Palette.onForest : Color.primary)
                .background(isSelected ? Palette.forest : Palette.cardBackground, in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.snappy, value: isSelected)
    }
}

#Preview {
    HStack {
        ChoiceCapsule(title: "Минск", isSelected: true) {}
        ChoiceCapsule(title: "Брест", isSelected: false) {}
    }
    .padding()
    .background(Palette.screenBackground)
}
