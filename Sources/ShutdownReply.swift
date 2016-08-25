//
//  ShutdownReply.swift
//  iSwiftCore
//
//  Created by Jin Wang on 28/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct ShutdownReply: Contentable {
    let restart: Bool
    
    func toJSON() -> [String : Any] {
        return ["restart": restart]
    }
    
    static func fromJSON(_ json: [String : Any]) -> ShutdownReply? {
        return nil
    }
}
