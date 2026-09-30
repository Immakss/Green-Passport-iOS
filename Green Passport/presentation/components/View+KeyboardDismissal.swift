import SwiftUI

extension View {
    func dismissesKeyboardOnBackgroundTap() -> some View {
        return background {
            Color.clear
                .contentShape(.rect)
                .onTapGesture(perform: Keyboard.dismiss)
        }
    }

    func dismissesKeyboardOnScroll() -> some View {
        return scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: Keyboard.dismiss) {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                    .accessibilityLabel(Text(.hideKeyboard))
                }
            }
    }
}
