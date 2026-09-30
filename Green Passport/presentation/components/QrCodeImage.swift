import CoreImage.CIFilterBuiltins
import SwiftUI

struct QrCodeImage: View {
    private static let correctionLevel = "M"

    let payload: String

    var body: some View {
        if let image = Self.render(payload) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
        }
    }

    private static func render(_ payload: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = correctionLevel
        guard let output = filter.outputImage,
              let cgImage = CIContext().createCGImage(output, from: output.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    QrCodeImage(payload: "GP7K2MXQ")
        .frame(width: 200, height: 200)
}
