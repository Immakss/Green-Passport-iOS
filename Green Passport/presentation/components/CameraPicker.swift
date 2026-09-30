import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    private static let captureQuality: CGFloat = 1

    let onImage: (Data) -> Void
    @Environment(\.dismiss) private var dismiss

    static var isAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> CameraPickerCoordinator {
        return CameraPickerCoordinator { image in
            if let image, let data = image.jpegData(compressionQuality: Self.captureQuality) {
                onImage(data)
            }
            dismiss()
        }
    }
}
