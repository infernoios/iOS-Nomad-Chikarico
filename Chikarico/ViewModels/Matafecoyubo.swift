import SwiftUI
@preconcurrency import WebKit
import Combine

class Matafecoyubo: ObservableObject {
    @Published var tovar: Bool = false
    @Published var taze: Bool = false

    @Published var yuvifapiv: Bool = false
    @Published var kiga: URLRequest? = nil
    @Published var mije: WKWebView? = nil

    @AppStorage(Wuzipij.Dazizogu.yenobez) var hoyakaqe: Bool = true
    @AppStorage(Wuzipij.Dazizogu.wudo) var zejahoku: String = Wuzipij.Dazizogu.pamiz
}
