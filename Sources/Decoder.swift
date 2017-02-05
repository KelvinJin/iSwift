//
//  Decoder.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

class Decoder {
    static func run(_ key: String, inMessageQueue: BlockingQueue<SerializedMessage>, outMessageQueue: BlockingQueue<Message>) {
        while true {
            // Take some message from the queue and check whether the signature matches the message.
            let message = inMessageQueue.take()
            
            Logger.debug.print("Decoding new message...")
            
            let signature = SHA256(key: key, dataList: [message.header, message.parentHeader, message.metadata, message.content]).hexDigest()
            
            if message.signature != signature {
                Logger.warning.print("Malformed incoming message with sigature \(message.signature.toUTF8String()) identity \(message.idents). The signature should be \(signature.toUTF8String())")
                continue
            }
            
            do {
                outMessageQueue.add(try message.toMessage())
            } catch {
                Logger.warning.print(error)
            }
        }
    }
}
