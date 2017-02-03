//
//  Socket+Message.swift
//  iSwiftCore
//
//  Created by Jin Wang on 25/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import ZeroMQ
import Dispatch

// We can only send message one by one. This is for sure.
private let SocketSendQueue = DispatchQueue(label: "iSwiftCore.Socket")

extension Socket {
    static func sendingMessage(_ socket: Socket, _ message: Message) throws {
        SocketSendQueue.sync {
            do {
                try _sendingMessage(socket, message)
            } catch {
                Logger.critical.print(error)
            }
        }
    }
    
    private static func _sendingMessage(_ socket: Socket, _ message: Message) throws {
        let messageBlobs = [Message.Delimiter, "",
                            message.header.toJSONString(), message.parentHeader?.toJSONString() ?? "{}", "{}",
                            message.content.toJSONString()]
        var dataBlobs = messageBlobs.flatMap { $0.data(using: .utf8) }
        
        Logger.info.print("Sending message with idents count: \(message.idents.count)")
        
        guard messageBlobs.count == dataBlobs.count else {
            Logger.warning.print("Converting to data error!")
            throw Error.generalError("Converting to data error!")
        }
        
        dataBlobs.insert(contentsOf: message.idents, at: 0)
        
        try _sendMessageDataList(socket, datas: dataBlobs)
    }
    
    private static func _sendMessageDataList(_ socket: Socket, datas: [Data]) throws {
        for (index, data) in datas.enumerated() {
            let sentOut = try socket.send(data, mode: index == datas.count - 1 ? [] : .SendMore)
            Logger.info.print("\(String.init(data: data, encoding: .utf8) ?? "Invalid String") has \(sentOut ? "" : "not") been sent.", sentOut)
        }
    }
}
