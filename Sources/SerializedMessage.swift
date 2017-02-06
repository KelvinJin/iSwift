//
//  SerializedMessage.swift
//  iSwift
//
//  Created by Jin on 5/2/17.
//
//

import Foundation

struct SerializedMessage {
    let idents: [Data]
    let signature: Data
    let header: Data
    let parentHeader: Data
    let metadata: Data
    let content: Data
    let extraBlobs: [Data]
    
    func toMessage() throws -> Message {
        
        func parse<T>(_ str: Data, converter: (([String: Any]) -> T?)) throws -> T {
            guard let json = str.toJSON() else {
                print(str)
                throw Error.socketError("Parse \(str) to JSON failed.")
            }
            
            guard let re = converter(json) else {
                throw Error.socketError("Parse JSON to \(T.self) failed.")
            }
            
            return re
        }
        
        // Must have a header.
        Logger.debug.print("Parsing header...")
        let h = try parse(header, converter: Header.fromJSON)
        
        // May not have a parent header.
        Logger.debug.print("Parsing parent header...")
        let pStr = try parse(parentHeader) { $0 }
        let p = Header.fromJSON(pStr)
        
        // Can be an empty metadata.
        Logger.debug.print("Parsing metadata...")
        let m = try parse(metadata) { $0 }
        
        // For content, it's a bit complicated.
        Logger.debug.print("Parsing content...")
        
        let converter: ([String: Any]) -> Contentable?
        switch h.msgType {
        case .KernelInfoRequest:
            converter = KernelInfoRequest.fromJSON
        case .ExecuteRequest:
            converter = ExecuteRequest.fromJSON
        case .HistoryRequest:
            converter = HistoryRequest.fromJSON
        case .IsCompleteRequest:
            converter = IsCompleteRequest.fromJSON
        case .ShutdownRequest:
            converter = ShutdownRequest.fromJSON
        case .CompleteRequest:
            converter = CompleteRequest.fromJSON
        default:
            throw Error.socketError("Undefined message content.")
        }
        
        let c = try parse(content, converter: converter)
        
        return Message(idents: idents, header: h, parentHeader: p, metadata: m, content: c, extraBlobs: extraBlobs)
    }
    
    static func fromMessage(_ message: Message, key: String) -> SerializedMessage {
        let h = message.header.toData()
        let p = message.parentHeader?.toData() ?? Message.EmptyDic.toData()
        let m = message.metadata.toData()
        let c = message.content.toData()
        let s = SHA256(key: key, dataList: [h, p, m, c]).hexDigest()
        
        return SerializedMessage(idents: message.idents, signature: s, header: h, parentHeader: p, metadata: m, content: c, extraBlobs: message.extraBlobs)
    }
}
