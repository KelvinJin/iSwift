//
//  Queue.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

#if os(Linux)
import CDispatch

let NSEC_PER_SEC = CDispatch.NSEC_PER_SEC
let DISPATCH_TIME_NOW = CDispatch.DISPATCH_TIME_NOW

// By default, this will be a FIFO queue.
class BlockingQueue<Element> {
    private var dataSource: ConcurrentArray<Element>
    private let dataSemaphore: dispatch_semaphore_t

    init() {
        dataSource = ConcurrentArray<Element>()
        dataSemaphore = dispatch_semaphore_create(0)
    }

    func add(_ e: Element) {
        dataSource.append(e)

        Logger.debug.print("Blocking Queue adding element.")

        // New data available.
        dispatch_semaphore_signal(dataSemaphore)
    }

    func take(_ timeout: NSTimeInterval? = nil) -> Element {
        let t: dispatch_time_t
        if let timeout = timeout {
            t = dispatch_time(DISPATCH_TIME_NOW, Int64(timeout * Double(NSEC_PER_SEC)))
        } else {
            t = DISPATCH_TIME_FOREVER
        }

        dispatch_semaphore_wait(dataSemaphore, t)

        // This will throw error if there's no element.
        return dataSource.removeFirst()
    }
}

#else

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

#endif
