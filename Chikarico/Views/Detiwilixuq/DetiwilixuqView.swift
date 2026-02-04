import SwiftUI
@preconcurrency import WebKit
import OneSignalFramework

struct Detiwilixuq: View {

    @State var fobiy: String = ""
    @State private var wajux: Bool?

    @State var qipikegi: String = ""
    @State var leket = false
    @State var kuneyekos = false

    @State private var fupet: Bool = true
    @State private var zikifehipa: Bool = true
    @AppStorage(Yiruyimitu.Wavezol.xazayive) var tagohi: Bool = true
    @AppStorage(Yiruyimitu.Wavezol.pecox) var cusozefar: Bool = true

    var body: some View {
        ZStack {
            if zikifehipa {
                SplashScreen(loading: true)
                    .zIndex(1)
            }

            if wajux != nil {
                if tagohi {
                    Dobaxuxe(
                        fobiy: $fobiy,
                        qipikegi: $qipikegi,
                        leket: $leket,
                        kuneyekos: $kuneyekos)
                    .opacity(0)
                    .zIndex(2)
                }

                if leket || !cusozefar {
                    Fesaco()
                        .zIndex(3)
                        .onAppear {
                            cusozefar = false
                            tagohi = false
                            zikifehipa = false
                        }
                }

                if kuneyekos {
                    if fupet {
                        SplashScreen(loading: true)
                            .zIndex(4)
                            .onAppear {
                                AppDelegate.orientationLock = .portrait
                                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: Yiruyimitu.Wavezol.qewuza)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { fupet = false }
                            }
                    } else {
                        HomeView()
                            .zIndex(5)
                    }
                }
            }
        }
        .animation(.easeInOut, value: zikifehipa)
        .onChange(of: kuneyekos) { if $0 { zikifehipa = false } }
        .onAppear {
            OneSignal.Notifications.requestPermission { wajux = $0 }

            guard let ruluhuvo = URL(string: Yiruyimitu.Duwuzahocet.yaro) else { return }

            URLSession.shared.dataTask(with: ruluhuvo) { keyarav, _, _ in
                guard let keyarav else { return }

                guard let bijukihava = try? JSONSerialization.jsonObject(with: keyarav, options: []) as? [String: Any] else { return }

                guard let cujigaciq = bijukihava[Yiruyimitu.Duwuzahocet.qetiy] as? String else { return }

                DispatchQueue.main.async { fobiy = cujigaciq }
            }
            .resume()
        }
    }
}

extension Detiwilixuq {

    struct Dobaxuxe: UIViewRepresentable {

        @Binding var fobiy: String
        @Binding var qipikegi: String
        @Binding var leket: Bool
        @Binding var kuneyekos: Bool

        func makeUIView(context: Context) -> WKWebView {
            let suku = WKWebView()
            suku.navigationDelegate = context.coordinator

            if let vifufulebu = URL(string: fobiy) {
                var voromaye = URLRequest(url: vifufulebu)
                voromaye.httpMethod = "GET"
                voromaye.setValue(Yiruyimitu.Wavezol.cizebizib, forHTTPHeaderField: Yiruyimitu.Wavezol.qigecive)

                let popi = [Yiruyimitu.Wavezol.sivuxihake: Yiruyimitu.Duwuzahocet.korugesa,
                                 Yiruyimitu.Wavezol.cegeqe: Yiruyimitu.Duwuzahocet.pipiwidan]
                for (gegi, losay) in popi {
                    voromaye.setValue(losay, forHTTPHeaderField: gegi)
                }

                suku.load(voromaye)
            }
            return suku
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {}

        func makeCoordinator() -> Senunuvi {
            Senunuvi(self)
        }

        class Senunuvi: NSObject, WKNavigationDelegate {

            var ziwugot: Dobaxuxe
            var jubep: String?
            var nene: String?

            init(_ wajajeqa: Dobaxuxe) {
                self.ziwugot = wajajeqa
            }

            func webView(_ hibajes: WKWebView, didFinish navigation: WKNavigation!) {
                hibajes.evaluateJavaScript(Yiruyimitu.Wavezol.vuwatu) { [unowned self] (zacu: Any?, error: Error?) in
                    guard let lipe = zacu as? String else {
                        ziwugot.kuneyekos = true
                        return
                    }

                    self.lavug(lipe)

                    hibajes.evaluateJavaScript(Yiruyimitu.Wavezol.naxecota) { (tudikano, error) in
                        if let ralolego = tudikano as? String {
                            self.nene = ralolego
                        }
                    }
                }
            }

            func lavug(_ hiketo: String) {
                guard let jimutudu = mudifiyo(from: hiketo) else {
                    ziwugot.kuneyekos = true
                    return
                }

                let joxu = jimutudu.trimmingCharacters(in: .whitespacesAndNewlines)

                guard let vikirumu = joxu.data(using: .utf8) else {
                    ziwugot.kuneyekos = true
                    return
                }

                do {
                    let johojub = try JSONSerialization.jsonObject(with: vikirumu, options: []) as? [String: Any]
                    guard let cediwo = johojub?[Yiruyimitu.Wavezol.puruguyom] as? String else {
                        ziwugot.kuneyekos = true
                        return
                    }

                    guard let hucixamayo = johojub?[Yiruyimitu.Wavezol.yazijotewe] as? String else {
                        ziwugot.kuneyekos = true
                        return
                    }

                    DispatchQueue.main.async {
                        self.ziwugot.fobiy = cediwo
                        self.ziwugot.qipikegi = hucixamayo
                    }

                    self.huri(with: cediwo)

                } catch {
                    print("\(Yiruyimitu.Wavezol.yojul)\(error.localizedDescription)")
                }
            }

            func mudifiyo(from hiketo: String) -> String? {
                guard let startRange = hiketo.range(of: "{"),
                      let endRange = hiketo.range(of: "}", options: .backwards) else {
                    return nil
                }

                let kowoku = String(hiketo[startRange.lowerBound..<endRange.upperBound])
                return kowoku
            }

            func huri(with femurutibo: String) {
                guard let gajekemaq = URL(string: femurutibo) else {
                    ziwugot.kuneyekos = true
                    return
                }

                qobe { mepigivubu in
                    guard let mepigivubu else {
                        return
                    }

                    self.jubep = mepigivubu

                    var honutedo = URLRequest(url: gajekemaq)
                    honutedo.httpMethod = "GET"
                    honutedo.setValue(Yiruyimitu.Wavezol.cizebizib, forHTTPHeaderField: Yiruyimitu.Wavezol.qigecive)

                    let noqa = [
                        Yiruyimitu.Wavezol.kajekuwab: Yiruyimitu.Duwuzahocet.mogibomiw,
                        Yiruyimitu.Wavezol.mucu: self.jubep ?? "",
                        Yiruyimitu.Wavezol.dovax: self.nene ?? "",
                        Yiruyimitu.Wavezol.makikarur: Locale.preferredLanguages.first ?? Yiruyimitu.Wavezol.qajaw
                    ]

                    for (jiroyumu, yoriquxa) in noqa {
                        honutedo.setValue(yoriquxa, forHTTPHeaderField: jiroyumu)
                    }

                    URLSession.shared.dataTask(with: honutedo) { [unowned self] fatu, soxexa, error in
                        guard let fatu, error == nil else {
                            print("\(Yiruyimitu.Wavezol.cefufaniwi)\(error?.localizedDescription.description ?? Yiruyimitu.Wavezol.cafayifuyi)")
                            ziwugot.kuneyekos = true
                            return
                        }
                        if let temoy = soxexa as? HTTPURLResponse {
                            print("\(Yiruyimitu.Wavezol.wecitiboy)\(temoy.statusCode)")

                            if temoy.statusCode == 200 {
                                self.fukopihe()
                            } else {
                                self.ziwugot.kuneyekos = true
                            }
                        }

                        if let hidasoh = String(data: fatu, encoding: .utf8) {
                            print("\(Yiruyimitu.Wavezol.qahawex)\(hidasoh)")
                        }
                    }.resume()
                }
            }

            func fukopihe() {

                let libu = self.ziwugot.qipikegi

                guard let nuyopu = URL(string: libu) else {
                    ziwugot.kuneyekos = true
                    return
                }

                var qumaco = URLRequest(url: nuyopu)
                qumaco.httpMethod = "GET"
                qumaco.setValue(Yiruyimitu.Wavezol.cizebizib, forHTTPHeaderField: Yiruyimitu.Wavezol.qigecive)

                let kuzugone = [
                    Yiruyimitu.Wavezol.kajekuwab: Yiruyimitu.Duwuzahocet.mogibomiw,
                    Yiruyimitu.Wavezol.mucu: self.jubep ?? "",
                    Yiruyimitu.Wavezol.dovax: self.nene ?? "",
                    Yiruyimitu.Wavezol.makikarur: Locale.preferredLanguages.first ?? Yiruyimitu.Wavezol.qajaw
                ]

                for (xajocerer, xozurokep) in kuzugone {
                    qumaco.setValue(xozurokep, forHTTPHeaderField: xajocerer)
                }

                URLSession.shared.dataTask(with: qumaco) { [unowned self] suze, muvapab, error in
                    guard let suze = suze, error == nil else {
                        ziwugot.kuneyekos = true
                        return
                    }

                    if let mehuqobo = String(data: suze, encoding: .utf8) {

                        do {
                            let jarozoxuso = try JSONSerialization.jsonObject(with: suze, options: []) as? [String: Any]
                            guard let buru = jarozoxuso?[Yiruyimitu.Wavezol.zelasozesi] as? String,
                                  let tehalilik = jarozoxuso?[Yiruyimitu.Wavezol.ginapiluyu] as? String,
                                  let riro = jarozoxuso?[Yiruyimitu.Wavezol.waqehitos] as? String else {

                                return
                            }

                            Bobipuy.shared.buru = buru
                            Bobipuy.shared.tehalilik = tehalilik
                            Bobipuy.shared.riro = riro

                            OneSignal.login(Bobipuy.shared.riro ?? "")
                            OneSignal.User.addTag(key: Yiruyimitu.Wavezol.nodeguse, value: Bobipuy.shared.tehalilik ?? "")

                            self.ziwugot.leket = true

                        } catch {
                            ziwugot.kuneyekos = true
                        }
                    }
                }.resume()
            }

            func qobe(completion: @escaping (String?) -> Void) {
                let dazem = URL(string: Yiruyimitu.Wavezol.xujagah)!
                let hari = URLSession.shared.dataTask(with: dazem) { vehid, fuwoneq, error in
                    guard let vehid, let ipAddress = String(data: vehid, encoding: .utf8) else {
                        completion(nil)
                        return
                    }
                    completion(ipAddress)
                }
                hari.resume()
            }
        }
    }
}
