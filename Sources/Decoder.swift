//
//  Decoder.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

class Decoder {
    static func run(_ key: String, inMessageQueue: BlockingQueue<Message>, outMessageQueue: BlockingQueue<Message>) {
        while true {
            // Take some message from the queue and check whether the signature matches the message.
            let message = inMessageQueue.take()
            
            Logger.debug.print("Decoding new message...")
            
            if let decodedMessage = decode(key, message: message) {
                outMessageQueue.add(decodedMessage)
            }
        }
    }
    
    static fileprivate func decode(_ key: String, message: Message) -> Message? {
//        return message.signature == message.toSHA256(key) ? message : nil
        return message
    }
}
