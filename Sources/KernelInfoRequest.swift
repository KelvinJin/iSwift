//
//  KernelInfoRequest.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct KernelInfoRequest: Contentable {
    func toJSON() -> [String : Any] {
        return [:]
    }
    
    static func fromJSON(_ json: [String : Any]) -> KernelInfoRequest? {
        return KernelInfoRequest()
    }
}
