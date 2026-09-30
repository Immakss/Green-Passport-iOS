import SwiftUI

struct SectionTitle: View {
    let title: LocalizedStringResource
    var actionTitle: LocalizedStringResource?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title2.bold())
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.medium))
                }
            }
        }
    }
}

#Preview {
    SectionTitle(title: .yourTasks, actionTitle: .all, action: {})
        .padding()
}
