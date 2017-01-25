//
//  SocketIn.swift
//  iSwiftCore
//
//  Created by Jin Wang on 23/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import ZeroMQ

class SocketIn {
    
    static func run(_ socket: Socket, outMessageQueue: BlockingQueue<Message>) {
        // Make sure the socket has been running.
        guard let _ = try? socket.getFileDescriptor() else { return }
        
        // Now, let's wait for the message identifier.
        var messageBlobs: [String] = []
        
        while true {
            do {
                if let recv: String = try socket.receive() {
                    Logger.debug.print("Get socket string: \(recv)")
                    if recv == Message.Delimiter {
                        // It seems to be a new message coming.
                        
                        // FIXME: Find a way to make this read extra blobs.
                        for _ in 0..<5 {
                            if let data: String = try socket.receive() {
                                Logger.debug.print("Get socket string: \(data)")
                                messageBlobs.append(data)
                            }
                        }
                        
                        do {
                            // Let's finish the previous one.
                            let message = try constructMessage(messageBlobs)
                            
                            // Added to the queue
                            outMessageQueue.add(message)
                        } catch let e {
                            Logger.info.print(e)
                        }
                        
                        // Remove the previous blobs.
                        messageBlobs.removeAll()
                    }
                }
            } catch let e {
                Logger.info.print(e)
            }
        }
    }
    
    static fileprivate func constructMessage(_ messageBlobs: [String]) throws -> Message {
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
        let extraBlobs: [String] = messageBlobs.count >= 6 ? messageBlobs.suffix(from: 5).flatMap { $0 } : []
        
        return Message(signature: signature, header: header, parentHeader: parentHeader, metadata: metadata, content: content, extraBlobs: extraBlobs)
    }
    
    static fileprivate func parse<T>(_ str: String, converter: (([String: Any]) -> T?)) throws -> T {
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
