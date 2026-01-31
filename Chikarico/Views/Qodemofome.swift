import SwiftUI
@preconcurrency import WebKit
import Combine

struct Qodemofome: View {

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var wukux: Honan
    let qeguwivop: URLRequest
    private var gizege: ((_ navigationAction: Qodemofome.Nacajixahex) -> Void)?

    let mirucaku = NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

    init(duzaquri: URL, wukux: Honan) {
        self.init(urlRequest: URLRequest(url: duzaquri), wukux: wukux)
    }

    private init(urlRequest: URLRequest, wukux: Honan) {
        self.qeguwivop = urlRequest
        self.wukux = wukux
    }

    var body: some View {

        ZStack{

            Kawohogowi(wukux: wukux,
                            mumejufe: gizege,
                            waqije: qeguwivop)

            ZStack {
                VStack{
                    HStack{
                        Button(action: {
                            wukux.nihib = true
                            wukux.xapusaz?.removeFromSuperview()
                            wukux.xapusaz?.superview?.setNeedsLayout()
                            wukux.xapusaz?.superview?.layoutIfNeeded()
                            wukux.xapusaz = nil
                            wukux.wajuhex = false
                        }) {
                            Image(systemName: Wugehison.Mobepevahixo.qefamoqafa)
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
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: Wugehison.Mobepevahixo.yeriq)
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
}

extension Qodemofome {
    enum Nacajixahex {
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
