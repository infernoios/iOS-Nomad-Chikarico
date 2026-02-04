import SwiftUI
@preconcurrency import WebKit
import OneSignalFramework

struct Qoyijuk: View {

    @State private var sumuc: Bool?
    @State private var xoketeme: String?
    @State private var fifaca: Bool = true
    @State private var femawiyizi: Bool = true

    @AppStorage(Yiruyimitu.Wavezol.dilumulisi) var jikubetona: Bool = true
    @AppStorage(Yiruyimitu.Wavezol.xezelus) var sorutab: Bool = false
    @AppStorage(Yiruyimitu.Wavezol.hiqano) private var xatiyuyeja: Bool = true
    
    private var ndklfvn: Bool {
        let kopkpo = DateComponents(year: 2026, month: 2, day: 7)
        let kolopo = Calendar.current
        guard let clskdlkf = kolopo.date(from: kopkpo) else { return true }
        return Date() < clskdlkf
    }

    var body: some View {

        ZStack {

            if sumuc != nil {
                if ndklfvn || xoketeme == Yiruyimitu.Duwuzahocet.gavodes || sorutab == true {

                    ZStack {
                        if femawiyizi {
                            SplashScreen(loading: femawiyizi)
                                .zIndex(1)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        femawiyizi = false
                                    }
                                }

                        } else {
                            HomeView()
                        }
                    }
                    .onAppear {
                        AppDelegate.orientationLock = .portrait
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: Yiruyimitu.Wavezol.qewuza)
                        fifaca = false
                        sorutab = true
                    }
                } else {
                    Detiwilixuq()
                        .onAppear { fifaca = false }
                }
            }

            if fifaca {
                SplashScreen(loading: sumuc ?? false)
            }
        }
        .onAppear {
            OneSignal.Notifications.requestPermission { sumuc = $0 }

            if jikubetona {
                guard let caxa = URL(string: Yiruyimitu.Duwuzahocet.yaro) else { return }

                URLSession.shared.dataTask(with: caxa) { wodutopibi, _, _ in
                    guard let wodutopibi else {
                        sorutab = true
                        return
                    }

                    guard let taxarixuso = try? JSONSerialization.jsonObject(with: wodutopibi, options: []) as? [String: Any] else { return }
                    guard let cakuh = taxarixuso[Yiruyimitu.Duwuzahocet.qetiy] as? String else { return }

                    DispatchQueue.main.async {
                        xoketeme = cakuh
                        jikubetona = false
                    }
                }
                .resume()
            }
        }
    }
}

#Preview {
    Qoyijuk()
}
