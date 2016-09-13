//
//  Kernel.swift
//  iSwiftCore
//
//  Created by Jin Wang on 17/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import ZeroMQ
import CommandLine
import C7
import Dispatch

private let loggerLevel = 30

enum Error: Swift.Error {
    case socketError(String)
    case generalError(String)
}

class Logger {
    struct Printer {
        let rawValue: Int
        func print(_ items: Any...) {
            if rawValue >= loggerLevel {
                Swift.print(items)
            }
        }
    }
    
    static let debug = Printer(rawValue: 10)
    static let info = Printer(rawValue: 20)
    static let warning = Printer(rawValue: 30)
    static let critical = Printer(rawValue: 40)
}

let connectionFileOption = StringOption(shortFlag: "f", longFlag: "file", required: true,
    helpMessage: "Path to the output file.")

extension String {    
    func toJSON() -> [String: Any]? {
        guard let data = data(using: String.Encoding.utf8),
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                Logger.info.print("Convert to JSON failed.")
                return nil
        }
        
        return json
    }
}

open class Kernel {
    open static let sharedInstance = Kernel()
    
    fileprivate var totalExecutionCount = 0
    
    let context = try? Context()
    let socketQueue = DispatchQueue(label: "com.uthoft.iswift.kernel.socketqueue",  attributes: Dispatch.DispatchQueue.Attributes.concurrent)
    
    open func start(_ arguments: [String]) throws {
        let cli = CommandLine(arguments: arguments)
        cli.addOptions(connectionFileOption)
        try! cli.parse()
        
        guard let connectionFilePath = connectionFileOption.value else {
            Logger.info.print("No connection file path given.")
            return
        }
        
        let connectionFileUrl = URL(fileURLWithPath: connectionFilePath)
        
        let connectionFileData = try Data(contentsOf: connectionFileUrl)
        let connectionFileJson = try JSONSerialization.jsonObject(with: connectionFileData, options: [])
        
        guard let connectionFile = connectionFileJson as? [String: Any], let connection = Connection.mapToObject(connectionFile) else {
            Logger.info.print("Connection file invalid. \(connectionFileJson)")
            return
        }
        
        Logger.info.print("Current connection: \(connection)")
        listen(connection)
    }
    
    fileprivate func listen(_ connection: Connection) {
        guard let context = context else {
            Logger.info.print("Context is not initialised.")
            return
        }
        
        do {
            try createSocket(context, transport: connection.transport, ip: connection.ip, port: connection.hbPort, type: SocketType.rep) { data, socket in
                // Logger.info.print("Received heart beat data.")
                let _ = try? socket.send(data)
            }
            
            try createSocket(context, transport: connection.transport, ip: connection.ip, port: connection.controlPort, type: SocketType.router) { data, socket in
                Logger.info.print("Received control data.")
                
            }
            
            let ioPubSocket = try createSocket(context, transport: connection.transport, ip: connection.ip, port: connection.iopubPort, type: .pub)
            
            NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "IOPubNotification"), object: nil, queue: nil)
            { (notification) -> Void in
                Logger.debug.print("Sending iopub message...")
                
                if let resultMessage = notification.object as? Message {
                    do {
                        try Socket.sendingMessage(ioPubSocket, resultMessage)
                    } catch let e {
                        Logger.critical.print(e)
                    }
                } else {
                    Logger.critical.print("Notification object invalid. This shouldn't happen!")
                }
            }
            
            try createSocket(context, transport: connection.transport, ip: connection.ip, port: connection.stdinPort, type: SocketType.router) { data, socket in
                Logger.info.print("Received stdin data.")
                
            }
            
            socketQueue.async {
                do {
                    try self.startShell(context, connection: connection)
                } catch let e {
                    print(e)
                }
            }
            
        } catch let e {
            Logger.info.print("Socket creation error: \(e)")
        }
        
        socketQueue.sync(flags: .barrier, execute: {
            Logger.info.print("Listening completed...")
        }) 
    }
    
    private func createSocket(_ context: Context, transport: TransportType, ip: String, port: Int, type: SocketType, dataHandler: @escaping (C7.Data, Socket) -> Void) throws {
        // Create a heart beat connection that will reply anything it receives.
        let socket = try context.socket(type)
        try socket.bind("\(transport.rawValue)://\(ip):\(port)")
        
        socketQueue.async {
            do {
                while let data = try socket.receive(), data.count > 0 {
                    dataHandler(data, socket)
                }
            } catch let e {
                Logger.info.print("Socket exception...\(e)")
            }
        }
    }
    
    private func createSocket(_ context: Context, transport: TransportType, ip: String, port: Int, type: SocketType) throws -> Socket {
        let socket = try context.socket(type)
        try socket.bind("\(transport.rawValue)://\(ip):\(port)")
        return socket
    }
    
    private func startShell(_ context: Context, connection: Connection) throws {
        let taskFactory = TaskFactory()
        let socket = try createSocket(context, transport: connection.transport, ip: connection.ip, port: connection.shellPort, type: .router)
        let inSocketMessageQueue = BlockingQueue<Message>()
        let decodedMessageQueue = BlockingQueue<Message>()
        let processedMessageQueue = BlockingQueue<Message>()
        let encodedMessageQueue = BlockingQueue<Message>()
        
        taskFactory.startNew {
            SocketIn.run(socket, outMessageQueue: inSocketMessageQueue)
        }
        
        taskFactory.startNew {
            Decoder.run(connection.key, inMessageQueue: inSocketMessageQueue, outMessageQueue: decodedMessageQueue)
        }
        
        taskFactory.startNew {
            MessageProcessor.run(decodedMessageQueue, outMessageQueue: processedMessageQueue)
        }
        
        taskFactory.startNew {
            Encoder.run(connection.key, inMessageQueue: processedMessageQueue, outMessageQueue: encodedMessageQueue)
        }
        
        taskFactory.startNew {
            SocketOut.run(socket, inMessageQueue: encodedMessageQueue)
        }
        taskFactory.waitAll()
    }
}
