//
//  Stack.swift
//  iSwiftCore
//
//  Created by Jin Wang on 25/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

class Stack<T> {
    fileprivate var dataSource: [T]
    
    var isEmpty: Bool {
        return dataSource.isEmpty
    }
    
    init() {
        self.dataSource = [T]()
    }
    
    func push(_ element: T) {
        dataSource.append(element)
    }
    
    func pop() -> T? {
        return dataSource.popLast()
    }
}
