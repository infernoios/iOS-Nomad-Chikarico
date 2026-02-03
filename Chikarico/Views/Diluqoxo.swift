import SwiftUI
@preconcurrency import WebKit

struct Diluqoxo: View {

    @StateObject var ququ: Matafecoyubo = Matafecoyubo()
    @State var loading: Bool = true

    var body: some View {
        ZStack {

            let lumoluqiqu = URL(string: Rohuhevuzuc.shared.timovoca ?? "") ?? URL(string: ququ.zejahoku)!

            Cukal(ximofoce: lumoluqiqu, ququ: ququ)
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
