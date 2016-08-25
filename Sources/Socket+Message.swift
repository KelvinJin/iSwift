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
private let SocketSendQueue = DispatchQueue(label: "iSwiftCore.Socket", attributes: [])

extension Socket {
    func sendMessage(_ message: Message) throws {
        SocketSendQueue.async() { [weak self] () -> Void in
            do {
                Logger.debug.print("Sending message header \(message.header)")
                Logger.debug.print("Sending message signature \(message.signature)")
                Logger.debug.print("Sending message content \(message.content)")
                let messageBlobs = [message.header.session, Message.Delimiter, message.signature,
                    message.header.toJSONString(), message.parentHeader?.toJSONString() ?? "{}", "{}",
                    message.content.toJSONString()]
                for (index, dataStr) in messageBlobs.enumerated() {
                    try self?.sendString(dataStr, mode: index == messageBlobs.count - 1 ? [] : .SendMore)
                }
            } catch let e {
                Logger.critical.print(e)
            }
        }
    }
}
