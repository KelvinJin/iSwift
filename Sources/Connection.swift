//
//  Connection.swift
//  iSwiftCore
//
//  Created by Jin Wang on 17/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

enum TransportType: String {
    case TCP = "tcp"
    case UDP = "udp"
}

enum SignatureSchemeType: String {
    case Sha256 = "hmac-sha256"
}

struct Connection {
    let controlPort: Int
    let shellPort: Int
    let transport: TransportType
    let signatureScheme: SignatureSchemeType
    let stdinPort: Int
    let hbPort: Int
    let ip: String
    let iopubPort: Int
    let key: String
    
    static func mapToObject(_ json: [String: AnyObject]) -> Connection? {
        guard let controlPort = json["control_port"] as? Int,
            shellPort = json["shell_port"] as? Int,
            transportTypeString = json["transport"] as? String,
            transport = TransportType(rawValue: transportTypeString),
            signatureSchemeString = json["signature_scheme"] as? String,
            signatureScheme = SignatureSchemeType(rawValue: signatureSchemeString),
            stdinPort = json["stdin_port"] as? Int,
            hbPort = json["hb_port"] as? Int,
            ip = json["ip"] as? String,
            iopubPort = json["iopub_port"] as? Int,
            key = json["key"] as? String
            else { return nil }
        
        return Connection(controlPort: controlPort, shellPort: shellPort, transport: transport, signatureScheme: signatureScheme, stdinPort: stdinPort, hbPort: hbPort, ip: ip, iopubPort: iopubPort, key: key)
    }
}
