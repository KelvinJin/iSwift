//
//  HistoryRequest.swift
//  iSwiftCore
//
//  Created by Jin Wang on 20/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct HistoryRequest: Contentable {
    /// If True, also return output history in the resulting dict.
    let output: Bool
    
     /// If True, return the raw input history, else the transformed input.
    let raw: Bool
    
    /// So far, this can be 'range', 'tail' or 'search'.
    let histAccessType: String
    
    /// If hist_access_type is 'range', get a range of input cells. session can
    /// be a positive session number, or a negative number to count back from
    /// the current session.
    let session: Int?
    
    /// start and stop are line numbers within that session.
    let start: Int?
    let stop: Int?
    
    /// If hist_access_type is 'tail' or 'search', get the last n cells.
    let n: Int?
    
    /// If hist_access_type is 'search', get cells matching the specified glob
    /// pattern (with * and ? as wildcards).
    let pattern: String?
    
    /// If hist_access_type is 'search' and unique is true, do not
    /// include duplicated history.  Default is false.
    let unique: Bool
    
    func toJSON() -> [String : Any] {
        return [:]
    }
    
    static func fromJSON(_ json: [String : Any]) -> HistoryRequest? {
        guard let histAccessType = json["hist_access_type"] as? String
            else { return nil }
        
        let start = json["start"] as? Int
        let stop = json["stop"] as? Int
        let pattern = json["pattern"] as? String
        let output = json["output"] as? Bool ?? false
        let session = json["session"] as? Int
        let raw = json["raw"] as? Bool ?? false
        let n = json["n"] as? Int
        let unique = json["unique"] as? Bool ?? false
        
        return HistoryRequest(output: output, raw: raw, histAccessType: histAccessType, session: session, start: start, stop: stop, n: n, pattern: pattern, unique: unique)
    }
}
