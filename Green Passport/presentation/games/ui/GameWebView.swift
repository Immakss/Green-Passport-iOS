import SwiftUI
import WebKit

struct GameWebView: UIViewRepresentable {
    static let bridgeName = "greenPassport"

    let url: URL
    let onMessage: (GameBridgeMessage) -> Void
    let onLoadingChange: (Bool) -> Void
    let onFailure: () -> Void

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: Self.bridgeName)
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: GameWebCoordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: bridgeName)
    }

    func makeCoordinator() -> GameWebCoordinator {
        return GameWebCoordinator(parent: self)
    }
}
