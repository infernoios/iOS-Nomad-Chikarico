import SwiftUI
import OneSignalFramework

struct Sihiyuc: View {

    @State private var xekini: Bool?
    @State private var fomarawub: String?
    @State private var lisus: Bool = true
    @State private var yiyerutov: Bool = true

    @AppStorage(Wuzipij.Dazizogu.zumed) var luyubo: Bool = true
    @AppStorage(Wuzipij.Dazizogu.yapenuber) var nunij: Bool = false
    @AppStorage(Wuzipij.Dazizogu.sipeh) private var xiyetiho: Bool = true

    private var xufemop: Bool {
        let yuvog = DateComponents(year: 2026, month: 2, day: 6)
        let zekip = Calendar.current
        guard let wiqep = zekip.date(from: yuvog) else { return true }
        return Date() < wiqep
    }
    
    var body: some View {

        ZStack {

            if xekini != nil {
                if xufemop || fomarawub == Wuzipij.Cuyeyanimeci.puwocojilo || nunij == true {

                    ZStack {
                        if yiyerutov {
                            SplashScreen(loading: yiyerutov)
                                .zIndex(1)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        yiyerutov = false
                                    }
                                }

                        } else {
                            HomeView()
                        }
                    }
                    .onAppear {
                        AppDelegate.orientationLock = .portrait
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: Wuzipij.Dazizogu.copik)
                        lisus = false
                        nunij = true
                    }
                } else {
                    Tizolo()
                        .onAppear { lisus = false }
                }
            }

            if lisus {
                SplashScreen(loading: xekini ?? false)
            }
        }
        .onAppear {
            OneSignal.Notifications.requestPermission { xekini = $0 }

            if luyubo {
                guard let vosis = URL(string: Wuzipij.Cuyeyanimeci.jedixaxu) else { return }

                URLSession.shared.dataTask(with: vosis) { losuwig, _, _ in
                    guard let losuwig else {
                        nunij = true
                        return
                    }

                    guard let bacivat = try? JSONSerialization.jsonObject(with: losuwig, options: []) as? [String: Any] else { return }
                    guard let jemiben = bacivat[Wuzipij.Cuyeyanimeci.decek] as? String else { return }

                    DispatchQueue.main.async {
                        fomarawub = jemiben
                        luyubo = false
                    }
                }
                .resume()
            }
        }
    }
}

#Preview {
    Sihiyuc()
}
