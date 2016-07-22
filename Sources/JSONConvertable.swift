//
//  JSONConvertable.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

protocol JSONConvertable {
    static func fromJSON(_ json: [String: AnyObject]) -> Self?
    func toJSON() -> [String: AnyObject]
}

extension JSONConvertable {
    func toData() -> Data { return toJSON().toData() }
    func toBytes() -> [UInt8] { return toJSON().toBytes() }
    func toJSONString() -> String {
        return (NSString(data: toData(), encoding: String.Encoding.utf8.rawValue) ?? "") as String
    }
}

extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
    func toData() -> Data {
        do {
            if let dict = (self as? AnyObject) as? Dictionary<String, AnyObject> {
                return try JSONSerialization.data(withJSONObject: dict, options: [])
            }
            return Data()
        } catch let e {
            print("NSJSONSerialization Error: \(e)")
            return Data()
        }
    }
    
    func toBytes() -> [UInt8] {
        let data = toData()
        let count = data.count
        var bytes = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&bytes, length: count)
        
        return bytes
    }
}
