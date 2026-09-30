import SwiftUI

struct TabStack<Root: View>: View {
    let container: AppDIContainer
    @Bindable var router: TabRouter
    @ViewBuilder let root: () -> Root

    var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .navigationDestination(for: AppDestination.self) { destination in
                    AppDestinationView(destination: destination, container: container)
                }
        }
        .environment(router)
    }
}
