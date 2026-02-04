import SwiftUI
@preconcurrency import WebKit

struct Fesaco: View {

    @StateObject var quve: Pelali = Pelali()
    @State var loading: Bool = true

    var body: some View {
        ZStack {

            let togu = URL(string: Bobipuy.shared.buru ?? "") ?? URL(string: quve.tuxawate)!

            Hugamocazoni(parifex: togu, quve: quve)
                .background(Color.black.ignoresSafeArea())
                .edgesIgnoringSafeArea(.bottom)
                .blur(radius: loading ? 15 : 0)

            if loading {
                ProgressView()
                    .controlSize(.large)
                    .tint(.pink)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                loading = false
            }
        }
    }
}
