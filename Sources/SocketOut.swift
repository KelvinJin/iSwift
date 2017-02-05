//
//  SocketOut.swift
//  iSwiftCore
//
//  Created by Jin Wang on 23/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import ZeroMQ

class SocketOut {
    static func run(_ socket: Socket, inMessageQueue: BlockingQueue<SerializedMessage>) {
        while true {
            do {
                // Blockingly take message from the queue.
                let message = inMessageQueue.take()
                
                Logger.debug.print("Sending out new message...")
                
                // Sequently send each part of the message.
                try Socket.sendingMessage(socket, message)
            } catch let e {
                Logger.info.print(e)
            }
        }
    }
}
