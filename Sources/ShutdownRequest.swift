//
//  ShutdownRequest.swift
//  iSwiftCore
//
//  Created by Jin Wang on 28/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct ShutdownRequest: Contentable {
    /// False if final shutdown, or True if shutdown precedes a restart
    let restart: Bool
    
    func toJSON() -> [String : AnyObject] {
        return [:]
    }
    
    static func fromJSON(_ json: [String : AnyObject]) -> ShutdownRequest? {
        let restart = json["restart"] as? Bool ?? false
        
        return ShutdownRequest(restart: restart)
    }
}
