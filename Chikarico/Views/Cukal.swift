import SwiftUI
@preconcurrency import WebKit
import Combine

struct Cukal: View {

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ququ: Matafecoyubo
    let maqipake: URLRequest
    private var giyagipu: ((_ navigationAction: Cukal.Ditoqafemeka) -> Void)?

    let worifuv = NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

    init(ximofoce: URL, ququ: Matafecoyubo) {
        self.init(urlRequest: URLRequest(url: ximofoce), ququ: ququ)
    }

    private init(urlRequest: URLRequest, ququ: Matafecoyubo) {
        self.maqipake = urlRequest
        self.ququ = ququ
    }

    var body: some View {

        ZStack{

            Warufifeju(ququ: ququ,
                            bowe: giyagipu,
                            zuqinimo: maqipake)

            ZStack {
                VStack{
                    HStack{
                        Button(action: {
                            ququ.taze = true
                            ququ.mije?.removeFromSuperview()
                            ququ.mije?.superview?.setNeedsLayout()
                            ququ.mije?.superview?.layoutIfNeeded()
                            ququ.mije = nil
                            ququ.yuvifapiv = false
                        }) {
                            Image(systemName: Wuzipij.Dazizogu.kutarino)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 20).padding(.top, 15)

                        Spacer()
                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
        .statusBarHidden(true)
        .onAppear {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.all
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: Wuzipij.Dazizogu.copik)
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
}

extension Cukal {
    enum Ditoqafemeka {
        case decidePolicy(WKNavigationAction, (WKNavigationActionPolicy) -> Void)
        case didRecieveAuthChallange(URLAuthenticationChallenge, (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
        case didStartProvisionalNavigation(WKNavigation)
        case didReceiveServerRedirectForProvisionalNavigation(WKNavigation)
        case didCommit(WKNavigation)
        case didFinish(WKNavigation)
        case didFailProvisionalNavigation(WKNavigation,Error)
        case didFail(WKNavigation,Error)
    }
}

struct Warufifeju : UIViewRepresentable {

    @ObservedObject var ququ: Matafecoyubo
    @State private var yede: NSKeyValueObservation?
    let zuqinimo: URLRequest
    @State private var kumi: WKWebView? = .init()

    init(ququ: Matafecoyubo,
         bowe: ((_ navigationAction: Cukal.Ditoqafemeka) -> Void)?,
         zuqinimo: URLRequest) {
        self.zuqinimo = zuqinimo
        self.ququ = ququ
        self.kumi = WKWebView()
        self.kumi?.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.kumi?.scrollView.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.kumi = WKWebView()

        self.kumi?.isOpaque = false
        viewDidLoad()
    }

    func viewDidLoad() {

        self.kumi?.backgroundColor = UIColor.black
        if #available(iOS 15.0, *) {
            yede = kumi?.observe(\.themeColor) { wadigavo, _ in
                self.kumi?.backgroundColor = wadigavo.themeColor ?? .systemBackground
            }
        }
    }

    func makeUIView(context: Context) -> WKWebView  {
        var beqe = WKWebView()
        let cenibuqo = WKPreferences()
        @ObservedObject var ququ: Matafecoyubo
        cenibuqo.javaScriptCanOpenWindowsAutomatically = true

        let poroyinu = WKWebViewConfiguration()
        poroyinu.allowsInlineMediaPlayback = true
        poroyinu.preferences = cenibuqo
        poroyinu.applicationNameForUserAgent = Wuzipij.Dazizogu.jisisozit
        beqe = WKWebView(frame: .zero, configuration: poroyinu)
        beqe.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        beqe.navigationDelegate = context.coordinator
        beqe.uiDelegate = context.coordinator
        beqe.load(zuqinimo)

        return beqe
    }

    func updateUIView(_ nubo: WKWebView, context: Context) {
        if nubo.canGoBack, ququ.taze {
            nubo.goBack()
            ququ.taze = false
        }
    }

    func makeCoordinator() -> Tabujiqare {
        return Tabujiqare(wowivu: self, konefobe: nil, ququ: self.ququ)
    }

    final class Tabujiqare: NSObject {
        var dofurabu: WKWebView?
        var wowivu: Warufifeju

        var ququ: Matafecoyubo
        let konefobe: ((_ navigationAction: Cukal.Ditoqafemeka) -> Void)?

        init(wowivu: Warufifeju, konefobe: ((_ navigationAction: Cukal.Ditoqafemeka) -> Void)?, ququ: Matafecoyubo) {
            self.wowivu = wowivu
            self.konefobe = konefobe
            self.ququ = ququ
            super.init()
        }
    }

}

extension Warufifeju.Tabujiqare: WKNavigationDelegate, WKUIDelegate {

    func webView(_ facohebene: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let response = navigationResponse.response as? HTTPURLResponse
        if let headers = response?.allHeaderFields as? [String: Any] {
            print("Response Headers: \(headers)")
        }
        decisionHandler(.allow)
    }

    func webView(_ facohebene: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let jodu = Wuzipij.Dazizogu.fikoyuf
        facohebene.evaluateJavaScript(jodu, completionHandler: nil)
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            facohebene.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }

        if konefobe == nil {
            decisionHandler(.allow)
        } else {
            konefobe?(.decidePolicy(navigationAction, decisionHandler))
        }
    }

    func webView(_ facohebene: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        konefobe?(.didStartProvisionalNavigation(navigation))
    }

    func webView(_ facohebene: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        konefobe?(.didReceiveServerRedirectForProvisionalNavigation(navigation))
    }

    func webView(_ facohebene: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        ququ.tovar = facohebene.canGoBack
        konefobe?(.didFailProvisionalNavigation(navigation, error))
    }

    func webView(_ facohebene: WKWebView, didCommit navigation: WKNavigation!) {
        konefobe?(.didCommit(navigation))
    }

    func webView(_ facohebene: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {

            let dofurabu = WKWebView(frame: facohebene.bounds, configuration: configuration)
            dofurabu.navigationDelegate = self
            dofurabu.uiDelegate = self
            facohebene.addSubview(dofurabu)
            facohebene.setNeedsLayout()
            facohebene.layoutIfNeeded()
            ququ.mije = dofurabu
            ququ.yuvifapiv = true
            return dofurabu
        }
        return nil
    }

    func webView(_ facohebene: WKWebView, didFinish navigation: WKNavigation!) {

        facohebene.allowsBackForwardNavigationGestures = true
        ququ.tovar = facohebene.canGoBack

        facohebene.configuration.mediaTypesRequiringUserActionForPlayback = .all
        facohebene.configuration.allowsInlineMediaPlayback = false
        facohebene.configuration.allowsAirPlayForMediaPlayback = false
        konefobe?(.didFinish(navigation))

        guard facohebene.url?.absoluteURL.absoluteString != nil else { return }

        if ququ.zejahoku == Wuzipij.Dazizogu.pamiz && self.ququ.hoyakaqe {
            self.ququ.zejahoku = facohebene.url!.absoluteString
            self.ququ.hoyakaqe = false
        }
    }

    func webView(_ facohebene: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        konefobe?(.didFail(navigation, error))
    }

    func webView(_ facohebene: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if konefobe == nil  {
            completionHandler(.performDefaultHandling, nil)
        } else {
            konefobe?(.didRecieveAuthChallange(challenge, completionHandler))
        }
    }

    func webViewDidClose(_ facohebene: WKWebView) {
        if facohebene == dofurabu {
            dofurabu?.removeFromSuperview()
            dofurabu = nil
        }
    }
}
