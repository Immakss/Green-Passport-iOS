import SwiftUI

struct HeroImageCard: View {
    private static let gradientOpacity: Double = 0.55

    let imageUrl: String?
    let title: String
    let subtitle: String
    var height: CGFloat = 200

    var body: some View {
        RemoteImage(url: imageUrl.flatMap(URL.init(string:)))
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .overlay {
                LinearGradient(
                    colors: [.clear, .black.opacity(Self.gradientOpacity)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    Text(title)
                        .font(.title3.bold())
                        .lineLimit(2)
                    Text(subtitle)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(Spacing.medium)
            }
            .clipShape(.rect(cornerRadius: CornerRadius.large, style: .continuous))
            .accessibilityElement(children: .combine)
    }
}

#Preview {
    HeroImageCard(imageUrl: nil, title: "Субботник в парке", subtitle: "12 октября · 10:00 · Минск")
        .padding()
}
