//
//  CompleteRequest.swift
//  iSwift
//
//  Created by Jin Wang on 6/2/17.
//
//

import Foundation

struct CompleteRequest: Contentable {
    let code: String
    let cursorPosition: Int
    
    static func fromJSON(_ json: [String : Any]) -> CompleteRequest? {
        guard let code = json["code"] as? String, let cursorPosition = json["cursor_pos"] as? Int else { return nil }
        
        return CompleteRequest(code: code, cursorPosition: cursorPosition)
    }
    
    func toJSON() -> [String : Any] {
        return [:]
    }
}
