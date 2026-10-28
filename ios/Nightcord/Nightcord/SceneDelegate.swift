/*
 * Nightcord, a Discord client mod
 * Copyright (c) 2026 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import UIKit
import WebKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = NightcordViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}

final class NightcordViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    private let webView: WKWebView

    init() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.javaScriptEnabled = true

        let script = NightcordViewController.makeInjectionScript()
        configuration.userContentController.addUserScript(script)
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let url = URL(string: "https://discord.com/app") {
            webView.load(URLRequest(url: url))
        }
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        return nil
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let host = navigationAction.request.url?.host?.lowercased() else {
            decisionHandler(.allow)
            return
        }

        if host == "discord.com" || host.hasSuffix(".discord.com") ||
            host == "discordapp.com" || host.hasSuffix(".discordapp.com") ||
            host == "discord.gg" || host.hasSuffix(".discord.gg") {
            decisionHandler(.allow)
        } else {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
            decisionHandler(.cancel)
        }
    }

    private static func makeInjectionScript() -> WKUserScript {
        let bundle = Bundle.main
        var source = ""

        if let jsURL = bundle.url(forResource: "Nightcord", withExtension: "js"),
           let js = try? String(contentsOf: jsURL, encoding: .utf8) {
            source.append(js)
        }

        if let cssURL = bundle.url(forResource: "Nightcord", withExtension: "css"),
           let css = try? String(contentsOf: cssURL, encoding: .utf8) {
            let escapedCSS = css.replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "`", with: "\\`")
                .replacingOccurrences(of: "${", with: "\\${")
            source.append("\n(() => { const style = document.createElement('style'); style.textContent = `\(escapedCSS)`; (document.head || document.documentElement).appendChild(style); })();")
        }

        return WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    }
}
