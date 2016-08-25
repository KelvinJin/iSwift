//
//  Header.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct Header: JSONConvertable {
    /// typically UUID, must be unique per message
    let msgId: String
    
    let username: String
    
    /// typically UUID, should be unique per session
    let session: String
    
    /// ISO 8601 timestamp for when the message is created
    let date: Date?
    
    /// All recognized message type strings are listed below
    let msgType: MessageType
    
    /// the message protocol version
    let version: String
    
    init(msgId: String = UUID().uuidString, username: String = "kernel",
         session: String, date: Date? = Date(), msgType: MessageType, version: String = "5.0") {
        self.msgId = msgId
        self.username = username
        self.session = session
        self.date = date
        self.msgType = msgType
        self.version = version
    }
    
    func toJSON() -> [String : Any] {
        var base = ["msg_id": msgId,
                    "username": username,
                    "session": session,
                    "msg_type": msgType.rawValue,
                    "version": version] as [String: Any]
        if let date = date {
            base["date"] = date.toISO8601String()
        }
        return base
    }
    
    static func fromJSON(_ json: [String : Any]) -> Header? {
        guard let msgId = json["msg_id"] as? String,
            let username = json["username"] as? String,
            let session = json["session"] as? String,
            let msgTypeStr = json["msg_type"] as? String,
            let msgType = MessageType(rawValue: msgTypeStr),
            let version = json["version"] as? String
            else { return nil }
        
        let date = (json["date"] as? String)?.toISO8601Date()
        
        return Header(msgId: msgId, username: username, session: session, date: date, msgType: msgType, version: version)
    }
}
