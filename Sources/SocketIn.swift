//
//  SocketIn.swift
//  iSwiftCore
//
//  Created by Jin Wang on 23/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import ZeroMQ

extension ZeroMQ.Message {
    var toData: Data {
        return Data(bytes: data, count: size)
    }
    
    var toString: String? {
        return String(data: toData, encoding: .utf8)
    }
}

extension Socket {
    // Enable the ability to receive messages that are very long. Such as those over 1024 bytes.
    func receiveMessageString(_ mode: ReceiveMode = []) throws -> String? {
        return try receiveMessage()?.toString
    }
    
    func receiveMessageDataList(_ mode: ReceiveMode = []) throws -> [Data] {
        var more = true
        var result: [Data] = []
        while more {
            guard let message = try receiveMessage() else { break }
            result.append(message.toData)
            more = message.more
        }
        return result
    }
}

extension String {
    func toJSON() -> [String: Any]? {
        guard let data = data(using: .utf8) else {
            Logger.warning.print("String.toJSON: Can't create data.")
            return nil
        }
        
        return data.toJSON()
    }
}

extension Data {
    func toJSON() -> [String : Any]? {
        guard let json = (try? JSONSerialization.jsonObject(with: self, options: [])) as? [String: Any] else {
            Logger.info.print("Convert to JSON failed.")
            return nil
        }
        
        return json
    }
}

class SocketIn {
    
    static func run(_ socket: Socket, outMessageQueue: BlockingQueue<Message>) {
        // Make sure the socket has been running.
        guard let _ = try? socket.getFileDescriptor() else { return }
        
        // Now, let's wait for the message identifier.
        var messageBlobs: [Data] = []
        
        while true {
            do {
                let datas = try socket.receiveMessageDataList()
                let idx = datas.split(whereSeparator: { String(data: $0, encoding: .utf8) == Message.Delimiter })
                
                guard idx.count == 2 else {
                    Logger.warning.print("Get invalid socket message")
                    continue
                }
                
                let idents = idx[0]
                let messageList = idx[1]
                
                for data in messageList {
                    Logger.debug.print("Get socket string: \(String(data: data, encoding: .utf8))")
                    messageBlobs.append(data)
                }
                
                do {
                    // Let's finish the previous one.
                    let message = try constructMessage(messageBlobs)
                    message.idents = idents.map { $0 }
                    
                    // Added to the queue
                    outMessageQueue.add(message)
                } catch let e {
                    Logger.info.print(e)
                }
                
                // Remove the previous blobs.
                messageBlobs.removeAll()
            } catch let e {
                Logger.info.print(e)
            }
        }
    }
    
    static fileprivate func constructMessage(_ messageBlobs: [Data]) throws -> Message {
        // Make sure there are enough blobs.
        guard messageBlobs.count >= 5 else {
            throw Error.socketError("message blobs are not enough.")
        }
        
        // Signature.
        let signature = messageBlobs[0]
        
        // Must have a header.
        Logger.debug.print("Parsing header...")
        let header = try parse(messageBlobs[1], converter: Header.fromJSON)
        
        // May not have a parent header.
        Logger.debug.print("Parsing parent header...")
        let parentHeaderStr = try parse(messageBlobs[2]) { $0 }
        let parentHeader = Header.fromJSON(parentHeaderStr)
        
        // Can be an empty metadata.
        Logger.debug.print("Parsing metadata...")
        let metadata = try parse(messageBlobs[3]) { $0 }
        
        // For content, it's a bit complicated.
        Logger.debug.print("Parsing content...")
        
        // FIXME: Rewrite the following codes.
        let content: Contentable
        switch header.msgType {
        case .KernelInfoRequest:
            content = try parse(messageBlobs[4], converter: KernelInfoRequest.fromJSON)
        case .ExecuteRequest:
            content = try parse(messageBlobs[4], converter: ExecuteRequest.fromJSON)
        case .HistoryRequest:
            content = try parse(messageBlobs[4], converter: HistoryRequest.fromJSON)
        case .IsCompleteRequest:
            content = try parse(messageBlobs[4], converter: IsCompleteRequest.fromJSON)
        case .ShutdownRequest:
            content = try parse(messageBlobs[4], converter: ShutdownRequest.fromJSON)
        default:
            throw Error.socketError("Undefined message content.")
        }
        
        // The rest would be extra blobs.
        Logger.debug.print("Parsing extraBlobs...")
        let extraBlobs: [Data] = messageBlobs.count >= 6 ? messageBlobs.suffix(from: 5).flatMap { $0 } : []
        
        return Message(signature: signature, header: header, parentHeader: parentHeader, metadata: metadata, content: content, extraBlobs: extraBlobs)
    }
    
    static fileprivate func parse<T>(_ str: Data, converter: (([String: Any]) -> T?)) throws -> T {
        guard let json = str.toJSON() else {
            print(str)
            throw Error.socketError("Parse \(str) to JSON failed.")
        }
        
        guard let re = converter(json) else {
            throw Error.socketError("Parse JSON to \(T.self) failed.")
        }
        
        return re
    }
}
