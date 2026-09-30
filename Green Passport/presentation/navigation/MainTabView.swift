import SwiftUI

struct MainTabView: View {
    let container: AppDIContainer

    var body: some View {
        TabView {
            Tab(String(localized: .home), systemImage: "house") {
                StateView(kind: .loading)
            }
            Tab(String(localized: .shop), systemImage: "bag") {
                StateView(kind: .loading)
            }
            Tab(String(localized: .map), systemImage: "map") {
                StateView(kind: .loading)
            }
            Tab(String(localized: .favorites), systemImage: "heart") {
                StateView(kind: .loading)
            }
        }
    }
}
