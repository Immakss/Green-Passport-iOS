import SwiftUI

struct MainTabView: View {
    let container: AppDIContainer

    @State private var homeRouter = TabRouter()
    @State private var shopRouter = TabRouter()
    @State private var mapRouter = TabRouter()
    @State private var favoritesRouter = TabRouter()

    var body: some View {
        TabView {
            Tab(String(localized: .home), systemImage: "house") {
                TabStack(container: container, router: homeRouter) {
                    HomeRoute(container: container)
                }
            }
            Tab(String(localized: .shop), systemImage: "bag") {
                TabStack(container: container, router: shopRouter) {
                    StateView(kind: .loading)
                }
            }
            Tab(String(localized: .map), systemImage: "map") {
                TabStack(container: container, router: mapRouter) {
                    StateView(kind: .loading)
                }
            }
            Tab(String(localized: .favorites), systemImage: "heart") {
                TabStack(container: container, router: favoritesRouter) {
                    StateView(kind: .loading)
                }
            }
        }
    }
}
