//
//  CompleteReply.swift
//  iSwift
//
//  Created by Jin Wang on 6/2/17.
//
//

import Foundation

struct CompleteReply: Contentable {
    let matches: [String]
    let cursorStart: Int
    let cursorEnd: Int
    let metadata: [String: Any] = [:]
    let status: String
    
    static func fromJSON(_ json: [String : Any]) -> CompleteReply? {
        return nil
    }
    
    func toJSON() -> [String : Any] {
        return ["matches" : matches, "cursor_start": cursorStart,
                "cursor_end": cursorEnd, "matadata": metadata, "status": status]
    }
}
