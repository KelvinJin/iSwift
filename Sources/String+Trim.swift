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

extension String {
    func toJSON() -> [String: Any]? {
        guard let data = data(using: .utf8) else {
            Logger.warning.print("String.toJSON: Can't create data.")
            return nil
        }
        
        return data.toJSON()
    }
    
    func toData() -> Data? {
        return data(using: .utf8)
    }
}

extension Data {
    func toJSON() -> [String : Any]? {
        guard let json = (try? JSONSerialization.jsonObject(with: self, options: [])) as? [String: Any] else {
            Logger.info.print("Convert to JSON failed.")
            return nil
        }
        
        return json
    }
}
