import SwiftUI

struct RemoteImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Image(.eventPlaceholder)
                    .resizable()
                    .scaledToFill()
            }
        }
        .accessibilityHidden(true)
    }
}
