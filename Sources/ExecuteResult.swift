//
//  ExecuteResult.swift
//  iSwiftCore
//
//  Created by Jin Wang on 25/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct ExecuteResult: Contentable {
    let executionCount: Int
    let data: [String: AnyObject]
    let metadata: [String: AnyObject]
    
    func toJSON() -> [String : AnyObject] {
        return ["execution_count": executionCount, "data": data, "metadata": metadata]
    }
    
    static func fromJSON(_ json: [String : AnyObject]) -> ExecuteResult? {
        return nil
    }
}
