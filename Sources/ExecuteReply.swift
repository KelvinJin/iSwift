//
//  ExecuteReply.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

enum ExecuteReplyStatus: String {
    case Ok = "ok"
    case Error = "error"
    case Abort = "abort"
}

struct ExecuteReply: Contentable {
    /// One of: 'ok' OR 'error' OR 'abort'
    let status: ExecuteReplyStatus
    
    /// The global kernel counter that increases by one with each request that
    /// stores history.  This will typically be used by clients to display
    /// prompt numbers to the user.  If the request did not store history, this will
    /// be the current value of the counter in the kernel.
    let executionCount: Int
    
    /// Results for the user_expressions.
    let userExpressions: UserExpressions?
    
    func toJSON() -> [String : Any] {
        var base = ["status": status.rawValue, "execution_count": executionCount] as [String: Any]
        
        if status == .Ok {
            if let userExpressions = userExpressions {
                base["user_expressions"] = userExpressions.toJSON()
            }
        }
        
        return base
    }
    
    static func fromJSON(_ json: [String : Any]) -> ExecuteReply? {
        return nil
    }
}
