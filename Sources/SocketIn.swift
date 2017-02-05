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

class SocketIn {
    
    static func run(_ socket: Socket, outMessageQueue: BlockingQueue<SerializedMessage>) {
        // Make sure the socket has been running.
        guard let _ = try? socket.getFileDescriptor() else { return }
        
        // Now, let's wait for the message identifier.
        var messageBlobs: [Data] = []
        
        while true {
            // Remove the previous blobs.
            messageBlobs.removeAll()
            
            do {
                let datas = try socket.receiveMessageDataList()
                let idx = datas.split(whereSeparator: { String(data: $0, encoding: .utf8) == Message.Delimiter })
                
                guard idx.count == 2 else {
                    Logger.warning.print("Get invalid socket message")
                    continue
                }
                
                for data in idx[1] {
                    Logger.debug.print("Get socket string: \(data.toUTF8String() ?? "Invalid String")")
                    messageBlobs.append(data)
                }
                
                do {
                    // Let's finish the previous one.
                    outMessageQueue.add(try constructMessage(idents: idx[0].map { $0 }, messageBlobs: messageBlobs))
                } catch let e {
                    Logger.info.print(e)
                }
            } catch let e {
                Logger.info.print(e)
            }
        }
    }
    
    static fileprivate func constructMessage(idents: [Data], messageBlobs: [Data]) throws -> SerializedMessage {
        // Make sure there are enough blobs.
        guard messageBlobs.count >= 5 else {
            throw Error.socketError("message blobs are not enough.")
        }
        
        return SerializedMessage(idents: idents, signature: messageBlobs[0], header: messageBlobs[1], parentHeader: messageBlobs[2], metadata: messageBlobs[3], content: messageBlobs[4], extraBlobs: messageBlobs.suffix(from: 5).flatMap { $0 })
    }
}
