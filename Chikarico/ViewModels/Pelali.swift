import SwiftUI
@preconcurrency import WebKit
import Combine

class Pelali: ObservableObject {
    @Published var joxow: Bool = false
    @Published var bibil: Bool = false

    @Published var dizek: Bool = false
    @Published var secida: URLRequest? = nil
    @Published var hoga: WKWebView? = nil

    @AppStorage(Yiruyimitu.Wavezol.masobivika) var hokitaco: Bool = true
    @AppStorage(Yiruyimitu.Wavezol.veret) var tuxawate: String = Yiruyimitu.Wavezol.gegomumo
}
