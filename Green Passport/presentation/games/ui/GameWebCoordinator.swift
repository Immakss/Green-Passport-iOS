import WebKit

final class GameWebCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    var parent: GameWebView

    init(parent: GameWebView) {
        self.parent = parent
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let bridgeMessage = GameBridgeMessage(body: message.body) else {
            return
        }
        parent.onMessage(bridgeMessage)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        parent.onLoadingChange(true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        parent.onLoadingChange(false)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        parent.onFailure()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        parent.onFailure()
    }
}
