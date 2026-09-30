import Foundation
import UIKit

final class JpegPhotoCompressor: PhotoCompressor {
    private static let maxDimension: CGFloat = 1600
    private static let quality: CGFloat = 0.85

    func compress(_ imageData: Data) throws -> Data {
        guard let image = UIImage(data: imageData) else {
            throw PhotoCompressionError()
        }
        let longestSide = max(image.size.width, image.size.height)
        let scale = min(1, Self.maxDimension / longestSide)
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        guard let jpegData = resized.jpegData(compressionQuality: Self.quality) else {
            throw PhotoCompressionError()
        }
        return jpegData
    }
}
