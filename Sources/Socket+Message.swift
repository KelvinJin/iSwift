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
private let EmptyDictionaryData = Message.EmptyDic.toData()

extension Socket {    
    static func sendingMessage(_ socket: Socket, _ message: SerializedMessage) throws {
        SocketSendQueue.sync {
            do {
                var dataList = [Message.Delimiter.toData()!, message.signature, message.header, message.parentHeader, message.metadata, message.content]
                
                Logger.info.print("Sending message with idents count: \(message.idents.count)")
                
                dataList.insert(contentsOf: message.idents, at: 0)
                try _sendMessageDataList(socket, datas: dataList)
            } catch {
                Logger.critical.print(error)
            }
        }
    }
    
    private static func _sendMessageDataList(_ socket: Socket, datas: [Data]) throws {
        for (index, data) in datas.enumerated() {
            let sentOut = try socket.send(data, mode: index == datas.count - 1 ? [] : .SendMore)
            Logger.info.print("\(String.init(data: data, encoding: .utf8) ?? "Invalid String") has \(sentOut ? "" : "not") been sent.", sentOut)
        }
    }
}
