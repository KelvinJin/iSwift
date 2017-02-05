//
//  Kernel.swift
//  iSwiftCore
//
//  Created by Jin Wang on 17/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import ZeroMQ
import CommandLineKit
import Dispatch

private let loggerLevel = 30

enum Error: Swift.Error {
    case socketError(String)
    case generalError(String)
}

class Logger {
    struct Printer {
        let rawValue: Int
        let tag: String
        func print(_ items: Any...) {
            if rawValue >= loggerLevel {
                Swift.print(tag, items, separator: " -- ")
            }
        }
    }
    
    static let debug = Printer(rawValue: 10, tag: "debug")
    static let info = Printer(rawValue: 20, tag: "info")
    static let warning = Printer(rawValue: 30, tag: "warning")
    static let critical = Printer(rawValue: 40, tag: "critical")
}

let connectionFileOption = StringOption(shortFlag: "f", longFlag: "file", required: true,
    helpMessage: "Path to the output file.")

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
        
        print(connection)
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
                Logger.info.print("Received control data. \(String(data: data, encoding: .utf8) ?? "Invalid String")")
            }
            
            let ioPubSocket = try createSocket(context, transport: connection.transport, ip: connection.ip, port: connection.iopubPort, type: .pub)
            
            NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "IOPubNotification"), object: nil, queue: nil)
            { (notification) -> Void in
                Logger.debug.print("Sending iopub message...")
                
                if let resultMessage = notification.object as? Message {
                    do {
                        try Socket.sendingMessage(ioPubSocket, SerializedMessage.fromMessage(resultMessage, key: connection.key))
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
            
            socketQueue.async { [unowned self] in
                do {
                    // try self.createMessageSocket(context, transport: connection.transport, ip: connection.ip, port: connection.iopubPort, key: connection.key, type: .pub)
                    try self.createMessageSocket(context, transport: connection.transport, ip: connection.ip, port: connection.shellPort, key: connection.key, type: .router)
                    Logger.info.print("Shell router is shutting down...")
                } catch let e {
                    Logger.critical.print(e)
                }
            }
            
        } catch let e {
            Logger.critical.print("Socket creation error: \(e)")
        }
        
        socketQueue.sync(flags: .barrier, execute: {
            Logger.critical.print("Listening completed...")
        }) 
    }
    
    private func createSocket(_ context: Context, transport: TransportType, ip: String, port: Int, type: SocketType, dataHandler: @escaping (Data, Socket) -> Void) throws {
        // Create a heart beat connection that will reply anything it receives.
        let socket = try context.socket(type)
        try socket.bind("\(transport.rawValue)://\(ip):\(port)")
        
        socketQueue.async {
            do {
                while let data: Data = try socket.receive(), data.count > 0 {
                    dataHandler(data, socket)
                }
            } catch let e {
                Logger.critical.print("Socket exception...\(e)")
            }
        }
    }
    
    private func createSocket(_ context: Context, transport: TransportType, ip: String, port: Int, type: SocketType) throws -> Socket {
        let socket = try context.socket(type)
        try socket.bind("\(transport.rawValue)://\(ip):\(port)")
        return socket
    }
    
    private func createMessageSocket(_ context: Context, transport: TransportType, ip: String, port: Int, key: String, type: SocketType) throws {
        let taskFactory = TaskFactory()
        let socket = try createSocket(context, transport: transport, ip: ip, port: port, type: type)
        let inSocketMessageQueue = BlockingQueue<SerializedMessage>()
        let decodedMessageQueue = BlockingQueue<Message>()
        let processedMessageQueue = BlockingQueue<Message>()
        let encodedMessageQueue = BlockingQueue<SerializedMessage>()
        
        taskFactory.startNew {
            SocketIn.run(socket, outMessageQueue: inSocketMessageQueue)
        }
        
        taskFactory.startNew {
            Decoder.run(key, inMessageQueue: inSocketMessageQueue, outMessageQueue: decodedMessageQueue)
        }
        
        taskFactory.startNew {
            MessageProcessor.run(decodedMessageQueue, outMessageQueue: processedMessageQueue)
        }
        
        taskFactory.startNew {
            Encoder.run(key, inMessageQueue: processedMessageQueue, outMessageQueue: encodedMessageQueue)
        }
        
        taskFactory.startNew {
            SocketOut.run(socket, inMessageQueue: encodedMessageQueue)
        }
        taskFactory.waitAll()
    }
}
