//
//  Queue.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

// By default, this will be a FIFO queue.
class BlockingQueue<Element> {
    private var dataSource: ConcurrentArray<Element>
    private let dataSemaphore: DispatchSemaphore
    
    init() {
        dataSource = ConcurrentArray<Element>()
        dataSemaphore = DispatchSemaphore(value: 0)
    }
    
    func add(_ e: Element) {
        dataSource.append(e)
        
        Logger.debug.print("Blocking Queue adding element.")
        
        // New data available.
        dataSemaphore.signal()
    }
    
    func take(_ timeout: TimeInterval? = nil) -> Element {
        let t: DispatchTime
        if let timeout = timeout {
            t = DispatchTime.now() + Double(Int64(timeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        } else {
            t = DispatchTime.distantFuture
        }
        
        dataSemaphore.wait(timeout: t)
        
        // This will throw error if there's no element.
        return dataSource.removeFirst()
    }
}
