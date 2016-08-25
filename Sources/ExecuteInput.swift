//
//  ExecuteInput.swift
//  iSwiftCore
//
//  Created by Jin Wang on 25/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct ExecuteInput: Contentable {
    let code: String
    let executionCount: Int

    func toJSON() -> [String : Any] {
        return ["code": code, "execution_count": executionCount]
    }

    static func fromJSON(_ json: [String : Any]) -> ExecuteInput? {
        return nil
    }
}
