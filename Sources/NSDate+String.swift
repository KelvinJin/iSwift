//
//  NSDate+String.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

private var ISO8601DateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    return dateFormatter
}

extension Date {
    func toISO8601String() -> String {
        return ISO8601DateFormatter.string(from: self)
    }
}

extension String {
    func toISO8601Date() -> Date? {
        return ISO8601DateFormatter.date(from: self)
    }
}
