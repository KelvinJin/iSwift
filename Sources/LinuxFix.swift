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
#endif

extension String {
    func isUUID() -> Bool {
        return UUID(uuidString: self) != nil
    }
}
