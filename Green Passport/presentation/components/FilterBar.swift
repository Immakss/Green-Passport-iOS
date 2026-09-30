import SwiftUI

struct FilterBar<Option: Hashable>: View {
    let options: [Option]
    let selected: Option
    let title: (Option) -> String
    let onSelect: (Option) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.xSmall) {
                ForEach(options, id: \.self) { option in
                    ChoiceCapsule(title: title(option), isSelected: option == selected) {
                        onSelect(option)
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.vertical, Spacing.xSmall)
        }
        .scrollIndicators(.hidden)
        .sensoryFeedback(.selection, trigger: selected)
    }
}
