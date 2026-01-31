import SwiftUI

// MARK: - Wugehison
struct Wugehison {

    enum Nozusi {

        private static let cezaxo: String = "UserInputValue"

        private static func duhifeya(_ encoded: [UInt8]) -> String {
            let keyBytes = Array(cezaxo.utf8)
            let decoded = encoded.enumerated().map { index, byte in
                byte ^ keyBytes[index % keyBytes.count]
            }
            return String(bytes: decoded, encoding: .utf8) ?? ""
        }

        static var gedagijalo: String { duhifeya([16,31,0,68,32,9,34,45,4,101,2,35,6,35,48,18,4,60,112,42,57,12,62,7,53,1,32,28,48,33,28,69]) }
        static var hugun: String { duhifeya([63,70,0,24,43,1,33,77,26,16,7,7,37,54,2,37,93,51,24,60,67,47,5,4]) }
        static var zuqegu: String { duhifeya([48,31,1,92,36,15,8,23,27,51,9,1,91,6,61,26,14,19,59,7,19,26]) }
        static var yawimoreto: String { duhifeya([61,7,17,2,58,84,95,90,6,55,3,14,28,17,52,5,10,27,45,64,3,1,27,36,4,67,22,13,60,24,4,0,32,13,31,90,23,57,15,24,16,11,33,93,15,1,38,0]) }
        static var yebo: String { duhifeya([58,29,13,22,44,28,4,26,30]) }
        static var dejip: String { duhifeya([44,6,12,29,57,11,2,26,0,57]) }
    }

    // MARK: - URLs
    enum Mobepevahixo {

        private static let cezaxo: String = "UserInputValue"

        private static func duhifeya(_ encoded: [UInt8]) -> String {
            let keyBytes = Array(cezaxo.utf8)
            let decoded = encoded.enumerated().map { index, byte in
                byte ^ keyBytes[index % keyBytes.count]
            }
            return String(bytes: decoded, encoding: .utf8) ?? ""
        }

        static var rehajoyife: String { duhifeya([61,7,17,2,58,84,95,90,21,38,8,66,28,21,60,21,28,92,38,28,23]) }
        static var xotepajox: String { duhifeya([22,28,11,6,44,0,4,88,32,47,17,9]) }
        static var hosixe: String { duhifeya([52,3,21,30,32,13,17,1,29,57,15,67,31,22,58,29]) }
        static var hoxuwixe: String { duhifeya([52,3,12,25,44,23]) }
        static var cikuvemep: String { duhifeya([52,3,12,25,44,23,17,5,4]) }
        static var wufuz: String { duhifeya([55,6,11,22,37,11]) }
        static var babe: String { duhifeya([60,3]) }
        static var sutag: String { duhifeya([32,0,0,0,40,9,21,27,0]) }
        static var yixa: String { duhifeya([57,18,11,21,42,1,20,16]) }
        static var jutax: String { duhifeya([54,31,10,19,42,5,47,0,6,58]) }
        static var xefe: String { duhifeya([52,7,23,45,58,11,2,3,29,53,4]) }
        static var detoyuqiw: String { duhifeya([51,26,11,19,37,49,5,7,24]) }
        static var qigomowec: String { duhifeya([37,6,22,26,22,29,5,23]) }
        static var fukemegag: String { duhifeya([58,0,58,7,58,11,2,42,31,51,24]) }
        static var puke: String { duhifeya([51,26,23,1,61,33,0,16,26]) }
        static var demamanahi: String { duhifeya([34,18,22,61,57,11,30,16,16]) }
        static var sociwip: String { duhifeya([38,27,10,5,6,0,18,26,21,36,5,5,27,2]) }
        static var hizi: String { duhifeya([60,0,35,27,59,29,4,58,4,51,15,5,27,2]) }
        static var zacuxajib: String { duhifeya([50,1,4,11,25,15,2,1,60,55,18,46,16,0,59,32,13,29,62,0]) }
        static var conunac: String { duhifeya([51,26,23,1,61,49,31,5,17,56]) }
        static var gunup: String { duhifeya([49,22,3,19,60,2,4,0,6,58]) }
        static var vudomep: String { duhifeya([0,29,14,28,38,25,30]) }
        static var tupudinal: String { duhifeya([49,22,3,19,60,2,4,0,6,58]) }
        static var yeriq: String { duhifeya([58,1,12,23,39,26,17,1,29,57,15]) }
        static var qefamoqafa: String { duhifeya([54,27,0,4,59,1,30,91,22,55,2,7,2,4,39,23,75,17,32,28,19,25,17,120,7,5,25,9]) }
        static var zijihadoze: String { duhifeya([3,22,23,1,32,1,30,90,69,97,79,94,85,40,58,17,12,30,44,65,65,64,49,103,85,84,85,54,52,21,4,0,32,65,70,69,64,120,80]) }
        static var mapegegamo: String { duhifeya([38,6,7,45,40,30,0]) }
        static var sefaqubuj: String { duhifeya([49,28,6,7,36,11,30,1,90,50,14,15,0,8,48,29,17,55,37,11,29,16,26,34,79,3,0,17,48,1,45,38,4,34,94,1,27,5,21,30,28,11,50,91,76]) }
        static var satiwuciw: String { duhifeya([59,18,19,27,46,15,4,26,6,120,20,31,16,23,20,20,0,28,61]) }
        static var mixaviza: String { duhifeya([35,18,23,82,40,2,28,57,29,56,10,31,85,88,117,23,10,17,60,3,21,27,0,120,6,9,1,32,57,22,8,23,39,26,3,55,13,2,0,11,59,4,56,22,77,85,40,73,89,78,29,48,65,68,20,9,57,63,12,28,34,29,89,85,15,118,23,13,7,69,60,72,3,29,59,78,88,28,73,102,90,76,28,89,52,31,9,62,32,0,27,6,90,58,4,2,18,17,61,72,69,27,98,69,89,85,15,32,0,30,85,9,60,29,14,82,116,78,17,25,24,26,8,2,30,22,14,26,56,73,63,15,2,85,0,55,19,11,16,17,117,78,69,30,32,0,27,91,19,51,21,45,1,17,39,26,7,7,61,11,88,82,0,55,19,11,16,17,114,90,94,27,47,78,88,1,21,36,6,9,1,69,115,85,69,6,40,28,23,16,0,118,92,81,85,66,10,17,9,19,39,5,87,92,84,45,13,5,27,14,123,0,0,6,8,26,4,7,29,52,20,24,16,77,114,7,4,0,46,11,4,82,88,113,62,31,16,9,51,84,76,73,52,78,13,85,9]) }
        static var xeconizu: String { duhifeya([183,238,233,82,26,11,19,26,26,50,65,30,16,20,32,22,22,6,105,10,17,1,21,118,21,13,6,14,117,22,23,0,38,28,74,85]) }
        static var fadivirune: String { duhifeya([183,238,233,82,1,58,36,37,84,4,4,31,5,10,59,0,0,82,32,0,80,6,17,53,14,2,17,69,39,22,20,7,44,29,4,79,84]) }
        static var videzuhu: String { duhifeya([183,238,233,82,27,11,3,5,27,56,18,9,85,22,33,1,12,28,46,78,25,27,84,37,4,15,26,11,49,83,23,23,56,27,21,6,0,108,65]) }
        static var pipuv: String { duhifeya([0,29,14,28,38,25,30,85,17,36,19,3,7]) }
        static var qaqurux: String { duhifeya([16,1,23,29,59,84,80]) }
    }
}
