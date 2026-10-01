import SwiftUI

struct MessageComposer: View {
    private static let lineLimit = 1...5

    @Binding var draft: String
    let placeholder: LocalizedStringResource
    let isSending: Bool
    let errorMessage: LocalizedStringResource?
    let onSend: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Palette.error)
                    .padding(.horizontal, Spacing.medium)
            }
            HStack(alignment: .bottom, spacing: Spacing.xSmall) {
                TextField(String(localized: placeholder), text: $draft, axis: .vertical)
                    .lineLimit(Self.lineLimit)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.small)
                    .glassEffect(in: .rect(cornerRadius: CornerRadius.large))
                Button(action: onSend) {
                    if isSending {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.headline)
                    }
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                .accessibilityLabel(Text(.forumPostButton))
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.bottom, Spacing.xSmall)
    }
}

#Preview {
    MessageComposer(
        draft: .constant(""),
        placeholder: .forumDraftLabel,
        isSending: false,
        errorMessage: .messageNotSentMsg,
        onSend: {}
    )
}
