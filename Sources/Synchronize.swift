//
//  Synchronize.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

protocol Lockable {
    var lock: NSLocking { get }
}

func synchronized<T>(_ lockable: Lockable, closure: () throws -> T) rethrows -> T {
    lockable.lock.lock()
    defer {
        lockable.lock.unlock()
    }
    return try closure()
}
