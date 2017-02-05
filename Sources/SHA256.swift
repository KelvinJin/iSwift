import Foundation
import Cryptor

extension UInt8 {
    fileprivate static let allHexits: [Character] = "0123456789abcdef".characters.flatMap { $0 }
    
    func toHex() -> String {
        let nybbles = [ Int(self >> 4), Int(self & 0x0F) ]
        let hexits = nybbles.map { nybble in UInt8.allHexits[nybble] }
        return String(hexits)
    }
}

extension Data {
    func toHexString() -> String {
        return flatMap { $0.toHex() }.reduce("", +)
    }
    
    func toUTF8String() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

class SHA256 {
    fileprivate let key: String
    fileprivate var dataList: [Data] = []
    
    init(key: String) {
        self.key = key
    }
    
    convenience init(key: String, dataList: [Data]) {
        self.init(key: key)
        self.dataList = dataList
    }
    
    func update(_ data: Data) {
        self.dataList.append(data)
    }
    
    func digest() -> [UInt8] {
        let hmac = HMAC(using: HMAC.Algorithm.sha256, key: key)
        
        for data in dataList {
            guard hmac.update(data: data) != nil else {
                Logger.critical.print("HMAC update failed.")
                return []
            }
        }
        
        return hmac.final()
    }
    
    // Takes a string representation of a hexadecimal number
    func hexDigest() -> Data {
        
        // FIXME: Figure out why our toHexString is equal to jupyter's toUTF8String.
        return Data(bytes: digest()).toHexString().toData()!
    }
}
