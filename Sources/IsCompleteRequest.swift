//
//  IsCompleteRequest.swift
//  iSwiftCore
//
//  Created by Jin Wang on 25/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct IsCompleteRequest: Contentable {
    let code: String
    
    func toJSON() -> [String : AnyObject] {
        return [:]
    }
    
    static func fromJSON(_ json: [String : AnyObject]) -> IsCompleteRequest? {
        guard let code = json["code"] as? String else { return nil }
        
        return IsCompleteRequest(code: code)
    }
}
