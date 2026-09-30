import SwiftUI

struct ExchangeScreen: View {
    var body: some View {
        StateView(kind: .empty(message: .exchangeUnavailableMessage))
            .background(Palette.screenBackground)
            .navigationTitle(Text(.exchangeScreenTitle))
    }
}

#Preview {
    NavigationStack {
        ExchangeScreen()
    }
}
