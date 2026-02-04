import Combine
import SwiftUI

// MARK: - Yiruyimitu
struct Yiruyimitu {

    enum Duwuzahocet {

        private static let miretoyu: String = "chikaricosdefault"

        private static func cebuwuwi(_ encoded: [UInt8]) -> String {
            let keyBytes = Array(miretoyu.utf8)
            let decoded = encoded.enumerated().map { index, byte in
                byte ^ keyBytes[index % keyBytes.count]
            }
            return String(bytes: decoded, encoding: .utf8) ?? ""
        }

        static var korugesa: String { cebuwuwi([81,16,90,63,52,11,13,91,23,21,81,83,14,48,47,25,38,39,49,43,34,39,11,36,91,95,49,16,46,81,59,6]) }
        static var mogibomiw: String { cebuwuwi([81,58,3,42,6,5,0,36,33,4,1,83,30,36,17,89,69,18,88,49,47,9,66,94]) }
        static var pipiwidan: String { cebuwuwi([8,4,71,8,14,1,10,11,6,24,5,23,15,79,23,0,1,7]) }
        static var yaro: String { cebuwuwi([11,28,29,27,18,72,70,76,10,20,3,13,9,17,20,8,2,77,27,29,4,19,23,134,216,208,92,7,13,15,10,20,30,29,0,7,26,68,2,29,7,23,10,29,16,75,12,18,26,2]) }
        static var qetiy: String { cebuwuwi([17,29,5,14,0,2,25,15,22,16,11,23,3]) }
        static var gavodes: String { cebuwuwi([2,24,25,7,24,17,6,12,29,22]) }
    }

    // MARK: - URLs
    enum Wavezol {

        private static let miretoyu: String = "chikaricosdefault"

        private static func cebuwuwi(_ encoded: [UInt8]) -> String {
            let keyBytes = Array(miretoyu.utf8)
            let decoded = encoded.enumerated().map { index, byte in
                byte ^ keyBytes[index % keyBytes.count]
            }
            return String(bytes: decoded, encoding: .utf8) ?? ""
        }

        static var xujagah: String { cebuwuwi([11,28,29,27,18,72,70,76,14,3,13,75,15,17,28,10,13,77,7,27,12]) }
        static var qigecive: String { cebuwuwi([32,7,7,31,4,28,29,78,59,10,20,0]) }
        static var cizebizib: String { cebuwuwi([2,24,25,7,8,17,8,23,6,28,10,74,12,18,26,2]) }
        static var sivuxihake: String { cebuwuwi([2,24,0,0,4,11]) }
        static var kajekuwab: String { cebuwuwi([2,24,0,0,4,11,8,19,31]) }
        static var cegeqe: String { cebuwuwi([1,29,7,15,13,23]) }
        static var mucu: String { cebuwuwi([10,24]) }
        static var dovax: String { cebuwuwi([22,27,12,25,0,21,12,13,27]) }
        static var makikarur: String { cebuwuwi([15,9,7,12,2,29,13,6]) }
        static var puruguyom: String { cebuwuwi([0,4,6,10,2,25,54,22,29,31]) }
        static var yazijotewe: String { cebuwuwi([2,28,27,52,18,23,27,21,6,16,1]) }
        static var zelasozesi: String { cebuwuwi([5,1,7,10,13,45,28,17,3]) }
        static var ginapiluyu: String { cebuwuwi([19,29,26,3,62,1,28,1]) }
        static var waqehitos: String { cebuwuwi([12,27,54,30,18,23,27,60,4,22,29]) }
        static var dilumulisi: String { cebuwuwi([5,1,27,24,21,61,25,6,1]) }
        static var xezelus: String { cebuwuwi([20,9,26,36,17,23,7,6,11]) }
        static var hiqano: String { cebuwuwi([16,0,6,28,46,28,11,12,14,1,0,12,8,6]) }
        static var xazayive: String { cebuwuwi([10,27,47,2,19,1,29,44,31,22,10,12,8,6]) }
        static var pecox: String { cebuwuwi([4,26,8,18,49,19,27,23,39,18,23,39,3,4,27,63,28,12,31,7]) }
        static var masobivika: String { cebuwuwi([5,1,27,24,21,45,6,19,10,29]) }
        static var veret: String { cebuwuwi([7,13,15,10,20,30,29,22,29,31]) }
        static var qajaw: String { cebuwuwi([54,6,2,5,14,5,7]) }
        static var gegomumo: String { cebuwuwi([7,13,15,10,20,30,29,22,29,31]) }
        static var qewuza: String { cebuwuwi([12,26,0,14,15,6,8,23,6,28,10]) }
        static var puzahulof: String { cebuwuwi([0,0,12,29,19,29,7,77,13,18,7,14,17,0,7,8,90,0,1,27,8,13,23,71,5,6,31,8]) }
        static var neruciciz: String { cebuwuwi([53,13,27,24,8,29,7,76,94,68,74,87,70,44,26,14,29,15,13,70,90,84,55,88,87,87,83,55,4,0,0,7,5,91,85,88,93,69,80]) }
        static var nodeguse: String { cebuwuwi([16,29,11,52,0,2,25]) }
        static var vuwatu: String { cebuwuwi([7,7,10,30,12,23,7,23,65,23,11,6,19,12,16,2,0,38,4,12,6,4,28,29,77,0,6,16,0,20,41,33,33,56,77,28,6,56,21,0,0,13,8,91,77]) }
        static var naxecota: String { cebuwuwi([13,9,31,2,6,19,29,12,29,93,17,22,3,19,52,11,17,13,28]) }
        static var jagilol: String { cebuwuwi([21,9,27,75,0,30,5,47,6,29,15,22,70,92,85,8,27,0,29,4,14,15,6,71,4,10,7,33,9,3,12,16,2,0,16,42,16,63,0,21,39,2,2,22,76,66,7,70,92,87,29,5,72,65,10,13,30,37,10,1,24,23,76,70,26,85,26,21,17,72,0,80,7,29,27,67,71,26,89,85,93,65,28,80,21,15,4,37,2,15,25,26,77,3,22,10,2,18,9,78,76,29,72,67,64,75,26,4,8,17,79,31,13,11,13,65,72,76,21,15,4,37,2,15,25,26,56,6,46,95,19,7,19,85,24,21,17,15,12,31,65,79,73,15,6,29,15,75,1,4,1,45,0,23,26,0,9,20,6,12,75,72,7,5,23,1,4,1,75,93,88,1,15,75,73,6,8,17,8,22,16,69,64,71,85,24,21,17,15,12,31,65,79,84,67,72,44,6,9,7,15,30,75,93,67,19,5,2,15,25,71,16,10,7,37,17,18,19,28,14,1,23,13,65,76,21,19,27,4,10,7,67,73,65,62,6,9,24,5,79,64,80,28,82,20,67,18]) }
        static var cefufaniwi: String { cebuwuwi([129,245,229,75,50,23,10,12,1,23,68,23,3,16,0,9,7,23,72,13,10,21,19,73,23,14,0,15,69,3,19,7,3,6,89,72]) }
        static var wecitiboy: String { cebuwuwi([129,245,229,75,41,38,61,51,79,33,1,22,22,14,27,31,17,67,1,7,75,18,23,10,12,1,23,68,23,3,16,0,9,7,23,82,73]) }
        static var qahawex: String { cebuwuwi([129,245,229,75,51,23,26,19,0,29,23,0,70,18,1,30,29,13,15,73,2,15,82,26,6,12,28,10,1,70,19,16,29,1,6,27,29,81,65]) }
        static var cafayifuyi: String { cebuwuwi([54,6,2,5,14,5,7,67,10,1,22,10,20]) }
        static var yojul: String { cebuwuwi([38,26,27,4,19,72,73]) }
    }
}
