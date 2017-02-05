//
//  Encoder.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

class Encoder {
    static func run(_ key: String, inMessageQueue: BlockingQueue<Message>, outMessageQueue: BlockingQueue<SerializedMessage>) {
        while true {
            // Take some message from the queue and check whether the signature matches the message.
            let message = inMessageQueue.take()
            
            Logger.debug.print("Encoding new message...\(message.header.msgType)")
            
            outMessageQueue.add(SerializedMessage.fromMessage(message, key: key))
        }
    }
}
