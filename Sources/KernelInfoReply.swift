//
//  KernelInfoReply.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

struct LanguageInfo: JSONConvertable {
    let name: String = "swift"
    let version: String = "2.1"
    let mimetype: String = "text/swift"
    let fileExtension: String = ".swift"
    
    func toJSON() -> [String : Any] {
        return ["name": name, "version": version, "mimetype": mimetype, "file_extension": fileExtension]
    }
    
    static func fromJSON(_ json: [String : Any]) -> LanguageInfo? {
        return nil
    }
}

struct KernelInfoReply: Contentable {
    let protocolVersion: String = "5.0"
    let implemetation: String = "iSwift"
    let implemetationVersion: String = "1.0.0"
    let languageInfo: LanguageInfo = LanguageInfo()
    let banner: String = "Swift Kernel - An Online Swift Playground"
    
    func toJSON() -> [String : Any] {
        return ["protocol_version": protocolVersion,
            "implemetation": implemetation,
            "implementation_version": implemetationVersion,
            "language_info": languageInfo.toJSON(),
            "banner": banner]
    }
    
    static func fromJSON(_ json: [String : Any]) -> KernelInfoReply? {
        return nil
    }
}
