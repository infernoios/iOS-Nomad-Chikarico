import SwiftUI
import OneSignalFramework

struct Jisuqopibe: View {

    @State private var kenuhera: Bool?
    @State private var bokuwam: String?
    @State private var duqogeni: Bool = true
    @State private var lelilu: Bool = true

    @AppStorage(Wugehison.Mobepevahixo.puke) var dapur: Bool = true
    @AppStorage(Wugehison.Mobepevahixo.demamanahi) var jehobuje: Bool = false
    @AppStorage(Wugehison.Mobepevahixo.sociwip) private var weqoziqequ: Bool = true
    
    private var xufemop: Bool {
        let yuvog = DateComponents(year: 2026, month: 2, day: 3)
        let zekip = Calendar.current
        guard let wiqep = zekip.date(from: yuvog) else { return true }
        return Date() < wiqep
    }

    var body: some View {

        ZStack {

            if kenuhera != nil {
                if xufemop || bokuwam == Wugehison.Nozusi.dejip || jehobuje == true {

                    ZStack {
                        if lelilu {
                            SplashScreen(loading: lelilu)
                                .zIndex(1)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        lelilu = false
                                    }
                                }

                        } else {
                            HomeView()
                        }
                    }
                    .onAppear {
                        AppDelegate.orientationLock = .portrait
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: Wugehison.Mobepevahixo.yeriq)
                        duqogeni = false
                        jehobuje = true
                    }
                } else {
                    Wamigejeteye()
                        .onAppear { duqogeni = false }
                }
            }

            if duqogeni {
                SplashScreen(loading: kenuhera ?? false)
            }
        }
        .onAppear {
            OneSignal.Notifications.requestPermission { kenuhera = $0 }

            if dapur {
                guard let ribihid = URL(string: Wugehison.Nozusi.yawimoreto) else { return }

                URLSession.shared.dataTask(with: ribihid) { xuqovej, _, _ in
                    guard let xuqovej else {
                        jehobuje = true
                        return
                    }

                    guard let xunaf = try? JSONSerialization.jsonObject(with: xuqovej, options: []) as? [String: Any] else { return }
                    guard let wepovo = xunaf[Wugehison.Nozusi.yebo] as? String else { return }

                    DispatchQueue.main.async {
                        bokuwam = wepovo
                        dapur = false
                    }
                }
                .resume()
            }
        }
    }
}

#Preview {
    Jisuqopibe()
}
