import SwiftUI

struct InputField: View {
    private static let fieldHeight: CGFloat = 50

    let title: LocalizedStringResource
    @Binding var text: String
    var error: LocalizedStringResource?
    var isSecure = false
    var contentType: UITextContentType?
    var keyboard: UIKeyboardType = .default

    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
            HStack(spacing: Spacing.xSmall) {
                field
                    .textContentType(contentType)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(isSecure || keyboard == .emailAddress ? .never : .words)
                    .autocorrectionDisabled()
                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .foregroundStyle(Palette.secondaryText)
                    }
                    .accessibilityLabel(Text(.showPassword))
                }
            }
            .padding(.horizontal, Spacing.medium)
            .frame(height: Self.fieldHeight)
            .background(Palette.cardBackground, in: .rect(cornerRadius: CornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .strokeBorder(error == nil ? .clear : Palette.error)
            }
            if let error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Palette.error)
                    .padding(.horizontal, Spacing.xxSmall)
            }
        }
    }

    @ViewBuilder
    private var field: some View {
        if isSecure && !isRevealed {
            SecureField(String(localized: title), text: $text)
        } else {
            TextField(String(localized: title), text: $text)
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    VStack {
        InputField(title: .email, text: $text, keyboard: .emailAddress)
        InputField(title: .password, text: $text, error: .passwordAtLeast6Characters, isSecure: true)
    }
    .padding()
    .background(Palette.screenBackground)
}
