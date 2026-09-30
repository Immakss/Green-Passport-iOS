import UIKit

final class CameraPickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let onFinish: (UIImage?) -> Void

    init(onFinish: @escaping (UIImage?) -> Void) {
        self.onFinish = onFinish
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        onFinish(info[.originalImage] as? UIImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        onFinish(nil)
    }
}
