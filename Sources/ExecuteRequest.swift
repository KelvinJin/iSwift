//
//  executeRequest.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct UserExpressions: JSONConvertable {
    let status: String?
    
    /// Exception name, as a string
    let ename: String?
    
    /// Exception value, as a string
    let evalue: String?
    
    /// The traceback will contain a list of frames, represented each as a
    /// string.  For now we'll stick to the existing design of ultraTB, which
    /// controls exception level of detail statefully.  But eventually we'll
    /// want to grow into a model where more information is collected and
    /// packed into the traceback object, with clients deciding how little or
    /// how much of it to unpack.  But for now, let's start with a simple list
    /// of strings, since that requires only minimal changes to ultratb as
    /// written.
    let traceback: [String]
    
    func toJSON() -> [String : Any] {
        return [:]
    }
    
    static func fromJSON(_ json: [String : Any]) -> UserExpressions? {
        return nil
    }
}

/**
 *  In order to obtain the current execution counter for the purposes of displaying input prompts, 
    frontends may make an execution request with an empty code string and silent=True.
 */
struct ExecuteRequest: Contentable {
    /// Source code to be executed by the kernel, one or more lines.
    let code: String
    
    /// A boolean flag which, if True, signals the kernel to execute
    /// this code as quietly as possible.
    /// silent=True forces store_history to be False,
    /// and will *not*:
    ///   - broadcast output on the IOPUB channel
    ///   - have an execute_result
    /// The default is False.
    let silent: Bool
    
    /// A boolean flag which, if True, signals the kernel to populate history
    /// The default is True if silent is False.  If silent is True, store_history
    /// is forced to be False.
    let storeHistory: Bool
    
    /// A dict mapping names to expressions to be evaluated in the
    /// user's dict. The rich display-data representation of each will be evaluated after execution.
    /// See the display_data content for the structure of the representation data.
    let userExpressions: UserExpressions
    
    /// Some frontends do not support stdin requests.
    /// If raw_input is called from code executed from such a frontend,
    /// a StdinNotImplementedError will be raised.
    let allowStdin: Bool
    
    /// A boolean flag, which, if True, does not abort the execution queue, if an exception is encountered.
    /// This allows the queued execution of multiple execute_requests, even if they generate exceptions.
    let stopOnError: Bool
    
    func toJSON() -> [String : Any] {
        return [:]
    }
    
    static func fromJSON(_ json: [String : Any]) -> ExecuteRequest? {
        guard let code = json["code"] as? String else { return nil }
        
        let silent = json["silent"] as? Bool ?? false
        let storeHistory = silent ? false : (json["store_history"] as? Bool ?? true)
        let userExpressions = UserExpressions(status: nil, ename: nil, evalue: nil, traceback: [])
        let allowStdin = json["allow_stdin"] as? Bool ?? true
        let stopOnError = json["stop_on_error"] as? Bool ?? false
        
        return ExecuteRequest(code: code, silent: silent,
            storeHistory: storeHistory, userExpressions: userExpressions,
            allowStdin: allowStdin, stopOnError: stopOnError)
    }
}
