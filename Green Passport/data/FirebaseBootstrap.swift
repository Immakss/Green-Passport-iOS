import FirebaseCore
import Foundation

enum FirebaseBootstrap {
    private static let configFileName = "GoogleService-Info"
    private static let configFileExtension = "plist"

    static func configure() -> Bool {
        guard Bundle.main.path(forResource: configFileName, ofType: configFileExtension) != nil else {
            return false
        }
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        return true
    }
}
