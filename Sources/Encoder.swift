//
//  Encoder.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

class Encoder {
    static func run(_ key: String, inMessageQueue: BlockingQueue<Message>, outMessageQueue: BlockingQueue<Message>) {
        while true {
            // Take some message from the queue and check whether the signature matches the message.
            var message = inMessageQueue.take()
            
            Logger.debug.print("Encoding new message...\(message.header.msgType)")
            
            encode(key, message: &message)
            outMessageQueue.add(message)
        }
    }
    
    static fileprivate func encode(_ key: String, message: inout Message) -> Message {
        message.signature = message.toSHA256(key)
        return message
    }
}
