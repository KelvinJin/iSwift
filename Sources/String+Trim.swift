//
//  String+Trim.swift
//  iSwiftCore
//
//  Created by Jin Wang on 25/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces).trimmingCharacters(in: CharacterSet.newlines)
    }
}
