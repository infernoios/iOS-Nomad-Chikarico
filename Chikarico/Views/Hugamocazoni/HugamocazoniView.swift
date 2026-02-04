import SwiftUI
@preconcurrency import WebKit
import Combine

struct Hugamocazoni: View {

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var quve: Pelali
    let jizihatozu: URLRequest
    private var jopo: ((_ navigationAction: Hugamocazoni.Keluta) -> Void)?

    let pivehomel = NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

    init(parifex: URL, quve: Pelali) {
        self.init(urlRequest: URLRequest(url: parifex), quve: quve)
    }

    private init(urlRequest: URLRequest, quve: Pelali) {
        self.jizihatozu = urlRequest
        self.quve = quve
    }

    var body: some View {

        ZStack{

            Lufexonadome(quve: quve,
                            nilewucu: jopo,
                            xeduqu: jizihatozu)

            ZStack {
                VStack{
                    HStack{
                        Button(action: {
                            quve.bibil = true
                            quve.hoga?.removeFromSuperview()
                            quve.hoga?.superview?.setNeedsLayout()
                            quve.hoga?.superview?.layoutIfNeeded()
                            quve.hoga = nil
                            quve.dizek = false
                        }) {
                            Image(systemName: Yiruyimitu.Wavezol.puzahulof)
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
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: Yiruyimitu.Wavezol.qewuza)
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
}

extension Hugamocazoni {
    enum Keluta {
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

struct Lufexonadome : UIViewRepresentable {

    @ObservedObject var quve: Pelali
    @State private var suya: NSKeyValueObservation?
    let xeduqu: URLRequest
    @State private var wipeyodof: WKWebView? = .init()

    init(quve: Pelali,
         nilewucu: ((_ navigationAction: Hugamocazoni.Keluta) -> Void)?,
         xeduqu: URLRequest) {
        self.xeduqu = xeduqu
        self.quve = quve
        self.wipeyodof = WKWebView()
        self.wipeyodof?.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.wipeyodof?.scrollView.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.wipeyodof = WKWebView()

        self.wipeyodof?.isOpaque = false
        viewDidLoad()
    }

    func viewDidLoad() {

        self.wipeyodof?.backgroundColor = UIColor.black
        if #available(iOS 15.0, *) {
            suya = wipeyodof?.observe(\.themeColor) { yolezo, _ in
                self.wipeyodof?.backgroundColor = yolezo.themeColor ?? .systemBackground
            }
        }
    }

    func makeUIView(context: Context) -> WKWebView  {
        var qugoyaka = WKWebView()
        let ciru = WKPreferences()
        @ObservedObject var quve: Pelali
        ciru.javaScriptCanOpenWindowsAutomatically = true

        let zasuqodise = WKWebViewConfiguration()
        zasuqodise.allowsInlineMediaPlayback = true
        zasuqodise.preferences = ciru
        zasuqodise.applicationNameForUserAgent = Yiruyimitu.Wavezol.neruciciz
        qugoyaka = WKWebView(frame: .zero, configuration: zasuqodise)
        qugoyaka.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        qugoyaka.navigationDelegate = context.coordinator
        qugoyaka.uiDelegate = context.coordinator
        qugoyaka.load(xeduqu)

        return qugoyaka
    }

    func updateUIView(_ nora: WKWebView, context: Context) {
        if nora.canGoBack, quve.bibil {
            nora.goBack()
            quve.bibil = false
        }
    }

    func makeCoordinator() -> Senunuvi {
        return Senunuvi(tucu: self, soqu: nil, quve: self.quve)
    }

    final class Senunuvi: NSObject {
        var pagidof: WKWebView?
        var tucu: Lufexonadome

        var quve: Pelali
        let soqu: ((_ navigationAction: Hugamocazoni.Keluta) -> Void)?

        init(tucu: Lufexonadome, soqu: ((_ navigationAction: Hugamocazoni.Keluta) -> Void)?, quve: Pelali) {
            self.tucu = tucu
            self.soqu = soqu
            self.quve = quve
            super.init()
        }
    }

}

extension Lufexonadome.Senunuvi: WKNavigationDelegate, WKUIDelegate {

    func webView(_ pakuwapomi: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let response = navigationResponse.response as? HTTPURLResponse
        if let headers = response?.allHeaderFields as? [String: Any] {
            print("Response Headers: \(headers)")
        }
        decisionHandler(.allow)
    }

    func webView(_ pakuwapomi: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let netene = Yiruyimitu.Wavezol.jagilol
        pakuwapomi.evaluateJavaScript(netene, completionHandler: nil)
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            pakuwapomi.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }

        if soqu == nil {
            decisionHandler(.allow)
        } else {
            soqu?(.decidePolicy(navigationAction, decisionHandler))
        }
    }

    func webView(_ pakuwapomi: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        soqu?(.didStartProvisionalNavigation(navigation))
    }

    func webView(_ pakuwapomi: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        soqu?(.didReceiveServerRedirectForProvisionalNavigation(navigation))
    }

    func webView(_ pakuwapomi: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        quve.joxow = pakuwapomi.canGoBack
        soqu?(.didFailProvisionalNavigation(navigation, error))
    }

    func webView(_ pakuwapomi: WKWebView, didCommit navigation: WKNavigation!) {
        soqu?(.didCommit(navigation))
    }

    func webView(_ pakuwapomi: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {

            let pagidof = WKWebView(frame: pakuwapomi.bounds, configuration: configuration)
            pagidof.navigationDelegate = self
            pagidof.uiDelegate = self
            pakuwapomi.addSubview(pagidof)
            pakuwapomi.setNeedsLayout()
            pakuwapomi.layoutIfNeeded()
            quve.hoga = pagidof
            quve.dizek = true
            return pagidof
        }
        return nil
    }

    func webView(_ pakuwapomi: WKWebView, didFinish navigation: WKNavigation!) {

        pakuwapomi.allowsBackForwardNavigationGestures = true
        quve.joxow = pakuwapomi.canGoBack

        pakuwapomi.configuration.mediaTypesRequiringUserActionForPlayback = .all
        pakuwapomi.configuration.allowsInlineMediaPlayback = false
        pakuwapomi.configuration.allowsAirPlayForMediaPlayback = false
        soqu?(.didFinish(navigation))

        guard pakuwapomi.url?.absoluteURL.absoluteString != nil else { return }

        if quve.tuxawate == Yiruyimitu.Wavezol.gegomumo && self.quve.hokitaco {
            self.quve.tuxawate = pakuwapomi.url!.absoluteString
            self.quve.hokitaco = false
        }
    }

    func webView(_ pakuwapomi: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        soqu?(.didFail(navigation, error))
    }

    func webView(_ pakuwapomi: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if soqu == nil  {
            completionHandler(.performDefaultHandling, nil)
        } else {
            soqu?(.didRecieveAuthChallange(challenge, completionHandler))
        }
    }

    func webViewDidClose(_ pakuwapomi: WKWebView) {
        if pakuwapomi == pagidof {
            pagidof?.removeFromSuperview()
            pagidof = nil
        }
    }
}
