//
//  Regex.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct Regex {
    var pattern: String {
        didSet {
            updateRegex()
        }
    }
    var expressionOptions: RegularExpression.Options {
        didSet {
            updateRegex()
        }
    }
    var matchingOptions: RegularExpression.MatchingOptions
    
    var regex: RegularExpression?
    
    init(pattern: String, expressionOptions: RegularExpression.Options = RegularExpression.Options(), matchingOptions: RegularExpression.MatchingOptions = RegularExpression.MatchingOptions()) {
        self.pattern = pattern
        self.expressionOptions = expressionOptions
        self.matchingOptions = matchingOptions
        updateRegex()
    }
    
    mutating func updateRegex() {
        regex = try? RegularExpression(pattern: pattern, options: expressionOptions)
    }
}


extension String {
    func matchRegex(_ pattern: Regex) -> Bool {
        let range: NSRange = NSMakeRange(0, utf8.count)
        if let regex = pattern.regex {
            let matches: [AnyObject] = regex.matches(in: self, options: pattern.matchingOptions, range: range)
            return matches.count > 0
        }
        return false
    }
    
    func match(_ patternString: String, options: RegularExpression.Options = [.anchorsMatchLines]) -> Bool {
        return self.matchRegex(Regex(pattern: patternString, expressionOptions: options))
    }
    
    func replaceRegex(_ pattern: Regex, template: String) -> String {
        if self.matchRegex(pattern) {
            let range: NSRange = NSMakeRange(0, utf8.count)
            if let regex = pattern.regex {
                return regex.stringByReplacingMatches(in: self, options: pattern.matchingOptions, range: range, withTemplate: template)
            }
        }
        return self
    }
    
    func replace(_ pattern: String, template: String) -> String {
        return self.replaceRegex(Regex(pattern: pattern), template: template)
    }
}
