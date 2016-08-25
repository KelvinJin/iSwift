//
//  LinuxFix.swift
//  iSwift
//
//  Created by Jin Wang on 28/7/16.
//
//

import Foundation

#if os(Linux)
let NSEC_PER_SEC: UInt64 = 1000000000
    
    typealias UUID = NSUUID
    
    extension UUID {
        var uuidString: String {
            return UUIDString
        }
    }
    
    extension NotificationCenter {
        class var `default`: NotificationCenter {
            return .defaultCenter()
        }
    }

    extension FileHandle {
        func waitForDataInBackgroundAndNotify(forModes modes: [RunLoopMode]) {
            let _modes = modes.map { $0.rawValue }
            waitForDataInBackgroundAndNotify(_modes)
        }
    }
#endif
