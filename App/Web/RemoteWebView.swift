import SwiftUI
import WebKit

/// 官方网页远控容器：加载 remote/v4 链接，界面原汁原味。
/// websiteDataStore 用默认持久化存储——Z.AI 登录态/cookie 落盘，重启免登录。
struct RemoteWebView: UIViewRepresentable {
    let url: URL
    @Binding var reloadToken: Int

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = .default()   // 持久化：保存登录信息
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        context.coordinator.webView = webView
        context.coordinator.lastURL = url
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastURL != url {
            context.coordinator.lastURL = url
            webView.load(URLRequest(url: url))
            return
        }
        if context.coordinator.lastReload != reloadToken {
            context.coordinator.lastReload = reloadToken
            webView.reload()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var webView: WKWebView?
        var lastURL: URL?
        var lastReload = 0
    }
}
