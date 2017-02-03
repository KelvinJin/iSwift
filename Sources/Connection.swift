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
    case IPC = "ipc"
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
    
    static func mapToObject(_ json: [String: Any]) -> Connection? {
        guard let controlPort = json["control_port"] as? Int,
            let shellPort = json["shell_port"] as? Int,
            let transportTypeString = json["transport"] as? String,
            let transport = TransportType(rawValue: transportTypeString),
            let signatureSchemeString = json["signature_scheme"] as? String,
            let signatureScheme = SignatureSchemeType(rawValue: signatureSchemeString),
            let stdinPort = json["stdin_port"] as? Int,
            let hbPort = json["hb_port"] as? Int,
            let ip = json["ip"] as? String,
            let iopubPort = json["iopub_port"] as? Int,
            let key = json["key"] as? String
            else { return nil }
        
        return Connection(controlPort: controlPort, shellPort: shellPort, transport: transport, signatureScheme: signatureScheme, stdinPort: stdinPort, hbPort: hbPort, ip: ip, iopubPort: iopubPort, key: key)
    }
}
