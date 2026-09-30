import VisionKit

final class QrScannerCoordinator: NSObject, DataScannerViewControllerDelegate {
    private let onCode: (String) -> Void
    private var hasDelivered = false

    init(onCode: @escaping (String) -> Void) {
        self.onCode = onCode
    }

    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        guard !hasDelivered else {
            return
        }
        for item in addedItems {
            if case .barcode(let barcode) = item, let payload = barcode.payloadStringValue {
                hasDelivered = true
                dataScanner.stopScanning()
                onCode(payload)
                return
            }
        }
    }
}
