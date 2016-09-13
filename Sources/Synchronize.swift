//
//  Synchronize.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

func synchronized<T>(_ lock: AnyObject, closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }
    return try closure()
}
