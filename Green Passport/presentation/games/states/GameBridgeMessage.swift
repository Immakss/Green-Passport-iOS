import Foundation

enum GameBridgeMessage {
    private static let typeKey = "type"
    private static let scoreKey = "score"
    private static let finishType = "finish"
    private static let closeType = "close"

    case finish(score: Int)
    case close

    init?(body: Any) {
        guard let payload = body as? [String: Any], let type = payload[Self.typeKey] as? String else {
            return nil
        }
        switch type {
        case Self.finishType:
            guard let score = (payload[Self.scoreKey] as? NSNumber)?.intValue else {
                return nil
            }
            self = .finish(score: score)
        case Self.closeType:
            self = .close
        default:
            return nil
        }
    }
}
