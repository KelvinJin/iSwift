//
//  SHA256.swift
//  CryptoCoin
//
//  Created by Sjors Provoost on 07-07-14.
//
//  Swift wrapper for CCHmac

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

open class SHA256 {
    fileprivate let key: String
    fileprivate var bytes: [UInt8] = []
    
    init(key: String) {
        self.key = key
    }
    
    func update(_ bytes: [UInt8]) {
        self.bytes.append(contentsOf: bytes)
    }
    
    func digest() -> [UInt8] {
        let hmac = HMAC(using: HMAC.Algorithm.sha256, key: key)
        
        return hmac.update(byteArray: bytes)!.final()
    }
    
    // Takes a string representation of a hexadecimal number
    func hexDigest() -> String {
        return digest().map { $0.toHex() }.reduce("", +)
    }
}
