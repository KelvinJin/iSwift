//
//  ConcurrentArray.swift
//  iSwiftCore
//
//  Created by Jin Wang on 25/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

class ConcurrentArray<T>: Lockable {
    fileprivate var dataSource: Array<T>
    var lock: NSLocking = NSLock()
    
    init() {
        self.dataSource = [T]()
    }
    
    func append(_ element: T) {
        synchronized(self) {
            dataSource.append(element)
        }
    }
    
    func removeLast() -> T {
        return synchronized(self) { () -> T in
            return dataSource.removeLast()
        }
    }
    
    func removeFirst() -> T {
        return synchronized(self) { () -> T in
            return dataSource.removeFirst()
        }
    }
    
    func removeAtIndex(_ index: Int) -> T {
        return synchronized(self) { () -> T in
            return dataSource.remove(at: index)
        }
    }
    
    func removeAll(_ keepCapacity: Bool = false) {
        synchronized(self) {
            dataSource.removeAll(keepingCapacity: keepCapacity)
        }
    }
}
