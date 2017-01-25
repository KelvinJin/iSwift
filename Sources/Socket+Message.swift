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
        let messageBlobs = [message.header.session, Message.Delimiter, "",
                            message.header.toJSONString(), message.parentHeader?.toJSONString() ?? "{}", "{}",
                            message.content.toJSONString()]
        for (index, dataStr) in messageBlobs.enumerated() {
            try socket.send(dataStr, mode: index == messageBlobs.count - 1 ? .DontWait : .SendMore)
        }
    }
}
