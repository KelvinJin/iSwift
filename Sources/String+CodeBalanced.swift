//
//  String+CodeBalanced.swift
//  iSwiftCore
//
//  Created by Jin Wang on 25/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

extension String {
    func isCompletedCode() -> Bool {
        let stack = Stack<Int>()
        let openBrackets: [Character] = ["(", "[", "{"]
        let closeBrackets: [Character] = [")", "]", "}"]
        
        for c in stripQuotes().characters {
            if let index = openBrackets.index(of: c) {
                stack.push(index)
            } else if let index = closeBrackets.index(of: c) {
                guard let openIndex = stack.pop() where openIndex == index else {
                    return false
                }
            }
        }
        
        return stack.isEmpty
    }
    
    func stripQuotes() -> String {
        // Remove \\ even number of back slash
        return replacingOccurrences(of: "\\\\", with: "")
        // Remove \" escaped quote.
        .replacingOccurrences(of: "\\\"", with: "")
        // Remove paired quotes.
        .replace("\"[^\"]*\"", template: "")
    }
}
