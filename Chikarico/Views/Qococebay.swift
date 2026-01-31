import SwiftUI
@preconcurrency import WebKit
import Combine

struct Qococebay: View {

    @StateObject var wukux: Honan = Honan()
    @State var loading: Bool = true

    var body: some View {
        ZStack {

            let rotuy = URL(string: Defonuju.shared.pucipocepa ?? "") ?? URL(string: wukux.poyex)!

            Qodemofome(duzaquri: rotuy, wukux: wukux)
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
