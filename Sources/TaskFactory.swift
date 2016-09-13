//
//  TaskFactory.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import Dispatch

class TaskFactory {
    fileprivate let taskQueue: DispatchQueue
    
    init() {
        taskQueue = DispatchQueue(label: "\(type(of: self)).\(UUID().uuidString)", qos: .userInitiated, attributes: .concurrent)
    }
    
    func startNew(_ taskBlock: @escaping ()->()) {
        taskQueue.async(execute: taskBlock)
    }
    
    func waitAll() {
        taskQueue.sync(flags: .barrier, execute: {}) 
    }
}
