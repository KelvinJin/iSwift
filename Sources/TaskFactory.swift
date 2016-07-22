//
//  TaskFactory.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

class TaskFactory {
    private let taskQueue: DispatchQueue
    
    init() {
        taskQueue = DispatchQueue(label: "\(self.dynamicType).\(UUID().uuidString)", attributes: DispatchQueueAttributes.concurrent)
    }
    
    func startNew(_ taskBlock: ()->()) {
        taskQueue.async(execute: taskBlock)
    }
    
    func waitAll() {
        taskQueue.sync(flags: .barrier, execute: {}) 
    }
}
