import GoogleSignIn
import SwiftUI

@main
struct GreenPassportApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let container: AppDIContainer?

    init() {
        container = FirebaseBootstrap.configure() ? AppDIContainer() : nil
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let container {
                    RootRoute(container: container)
                } else {
                    FirebaseMissingScreen()
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
