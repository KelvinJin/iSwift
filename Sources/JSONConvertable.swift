//
//  JSONConvertable.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import Jay

protocol JSONConvertable {
    static func fromJSON(_ json: [String: Any]) -> Self?
    func toJSON() -> [String: Any]
}

extension JSONConvertable {
    func toData() -> Data { return toJSON().toData() }
//    func toBytes() -> [UInt8] { return toJSON().toBytes() }
    func toJSONString() -> String {
        return (String(data: toData(), encoding: .utf8) ?? "")
    }
}

extension Dictionary {
    func toData() -> Data {
        do {
            let bytes = try Jay(formatting: .minified).dataFromJson(any: self)
            return Data(bytes: bytes)
        } catch let e {
            Logger.critical.print("NSJSONSerialization Error: \(e)")
            return Data()
        }
    }
}
