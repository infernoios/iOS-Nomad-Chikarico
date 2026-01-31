import SwiftUI
@preconcurrency import WebKit

struct Kawohogowi : UIViewRepresentable {

    @ObservedObject var wukux: Honan
    @State private var leyiqix: NSKeyValueObservation?
    let waqije: URLRequest
    @State private var royirak: WKWebView? = .init()

    init(wukux: Honan,
         mumejufe: ((_ navigationAction: Qodemofome.Nacajixahex) -> Void)?,
         waqije: URLRequest) {
        self.waqije = waqije
        self.wukux = wukux
        self.royirak = WKWebView()
        self.royirak?.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.royirak?.scrollView.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.royirak = WKWebView()

        self.royirak?.isOpaque = false
        viewDidLoad()
    }

    func viewDidLoad() {

        self.royirak?.backgroundColor = UIColor.black
        if #available(iOS 15.0, *) {
            leyiqix = royirak?.observe(\.themeColor) { mifequr, _ in
                self.royirak?.backgroundColor = mifequr.themeColor ?? .systemBackground
            }
        }
    }

    func makeUIView(context: Context) -> WKWebView  {
        var nesipire = WKWebView()
        let jezixiras = WKPreferences()
        @ObservedObject var wukux: Honan
        jezixiras.javaScriptCanOpenWindowsAutomatically = true

        let hetiv = WKWebViewConfiguration()
        hetiv.allowsInlineMediaPlayback = true
        hetiv.preferences = jezixiras
        hetiv.applicationNameForUserAgent = Wugehison.Mobepevahixo.zijihadoze
        nesipire = WKWebView(frame: .zero, configuration: hetiv)
        nesipire.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        nesipire.navigationDelegate = context.coordinator
        nesipire.uiDelegate = context.coordinator
        nesipire.load(waqije)

        return nesipire
    }

    func updateUIView(_ sapiwa: WKWebView, context: Context) {
        if sapiwa.canGoBack, wukux.nihib {
            sapiwa.goBack()
            wukux.nihib = false
        }
    }

    func makeCoordinator() -> Kudokut {
        return Kudokut(mevoruh: self, heqogono: nil, wukux: self.wukux)
    }

    final class Kudokut: NSObject {
        var rumegaluxa: WKWebView?
        var mevoruh: Kawohogowi

        var wukux: Honan
        let heqogono: ((_ navigationAction: Qodemofome.Nacajixahex) -> Void)?

        init(mevoruh: Kawohogowi, heqogono: ((_ navigationAction: Qodemofome.Nacajixahex) -> Void)?, wukux: Honan) {
            self.mevoruh = mevoruh
            self.heqogono = heqogono
            self.wukux = wukux
            super.init()
        }
    }

}

extension Kawohogowi.Kudokut: WKNavigationDelegate, WKUIDelegate {

    func webView(_ lacafoy: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let response = navigationResponse.response as? HTTPURLResponse
        if let headers = response?.allHeaderFields as? [String: Any] {
            print("Response Headers: \(headers)")
        }
        decisionHandler(.allow)
    }

    func webView(_ lacafoy: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let sehizacoyi = Wugehison.Mobepevahixo.mixaviza
        lacafoy.evaluateJavaScript(sehizacoyi, completionHandler: nil)
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            lacafoy.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }

        if heqogono == nil {
            decisionHandler(.allow)
        } else {
            heqogono?(.decidePolicy(navigationAction, decisionHandler))
        }
    }

    func webView(_ lacafoy: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        heqogono?(.didStartProvisionalNavigation(navigation))
    }

    func webView(_ lacafoy: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        heqogono?(.didReceiveServerRedirectForProvisionalNavigation(navigation))
    }

    func webView(_ lacafoy: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        wukux.vefoqo = lacafoy.canGoBack
        heqogono?(.didFailProvisionalNavigation(navigation, error))
    }

    func webView(_ lacafoy: WKWebView, didCommit navigation: WKNavigation!) {
        heqogono?(.didCommit(navigation))
    }

    func webView(_ lacafoy: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {

            let rumegaluxa = WKWebView(frame: lacafoy.bounds, configuration: configuration)
            rumegaluxa.navigationDelegate = self
            rumegaluxa.uiDelegate = self
            lacafoy.addSubview(rumegaluxa)
            lacafoy.setNeedsLayout()
            lacafoy.layoutIfNeeded()
            wukux.xapusaz = rumegaluxa
            wukux.wajuhex = true
            return rumegaluxa
        }
        return nil
    }

    func webView(_ lacafoy: WKWebView, didFinish navigation: WKNavigation!) {

        lacafoy.allowsBackForwardNavigationGestures = true
        wukux.vefoqo = lacafoy.canGoBack

        lacafoy.configuration.mediaTypesRequiringUserActionForPlayback = .all
        lacafoy.configuration.allowsInlineMediaPlayback = false
        lacafoy.configuration.allowsAirPlayForMediaPlayback = false
        heqogono?(.didFinish(navigation))

        guard lacafoy.url?.absoluteURL.absoluteString != nil else { return }

        if wukux.poyex == Wugehison.Mobepevahixo.tupudinal && self.wukux.veganom {
            self.wukux.poyex = lacafoy.url!.absoluteString
            self.wukux.veganom = false
        }
    }

    func webView(_ lacafoy: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        heqogono?(.didFail(navigation, error))
    }

    func webView(_ lacafoy: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if heqogono == nil  {
            completionHandler(.performDefaultHandling, nil)
        } else {
            heqogono?(.didRecieveAuthChallange(challenge, completionHandler))
        }
    }

    func webViewDidClose(_ lacafoy: WKWebView) {
        if lacafoy == rumegaluxa {
            rumegaluxa?.removeFromSuperview()
            rumegaluxa = nil
        }
    }
}
