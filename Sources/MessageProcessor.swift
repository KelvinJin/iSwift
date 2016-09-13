//
//  MessageProcessor.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import Dispatch

class MessageProcessor {
    static var executionCount: Int {
        _executionCount += 1
        return _executionCount
    }
    
    static var _executionCount: Int = 0
    
    static var session: String = ""
    
    #if os(Linux)
    
    // FIXME, need to find a better way to specify the path of the swift command.
    fileprivate static let replWrapper = try! REPLWrapper(command: "/root/swift-DEVELOPMENT-SNAPSHOT-2016-09-11-a-ubuntu14.04/usr/bin/swift", prompt: "^\\s*\\d+>\\s*$", continuePrompt: "^\\s*\\d+\\.\\s*$")
    
    #else
    
    fileprivate static let replWrapper = try! REPLWrapper(command: "/usr/bin/swift", prompt: "^\\s*\\d+>\\s*$", continuePrompt: "^\\s*\\d+\\.\\s*$")
    
    #endif
    
    static func run(_ inMessageQueue: BlockingQueue<Message>, outMessageQueue: BlockingQueue<Message>) {
        while true {
            let message = inMessageQueue.take()
            let requestHeader = message.header
            
            Logger.debug.print("Processing new message...\(message.header.msgType)")
            
            guard let replyType = requestHeader.msgType.replyType else { continue }
            
            let replyHeader = Header(session: requestHeader.session, msgType: replyType)
            
            let replyContent: Contentable
            switch replyType {
            case .KernelInfoReply:
                replyContent = KernelInfoReply()
            case .HistoryReply:
                replyContent = HistoryReply(history: [])
            case .ExecuteReply:
                let _currentExecutionCount = executionCount
                replyContent = ExecuteReply(status: .Ok, executionCount: _currentExecutionCount, userExpressions: nil)
                if let executeRequest = message.content as? ExecuteRequest {
                    execute(executeRequest.code, executionCount: _currentExecutionCount, parentHeader: requestHeader, metadata: [:])
                }
            case .IsCompleteReply:
                let content = message.content as! IsCompleteRequest
                replyContent = IsCompleteReply(status: content.code.isCompletedCode() ? "complete" : "incomplete", indent: nil)
            case .ShutdownReply:
                let content = message.content as! ShutdownRequest
                
                Logger.info.print("Shutting down...")
                
                do {
                    try replWrapper.shutdown(content.restart)
                } catch let e {
                    Logger.critical.print(e)
                }
                
                replyContent = ShutdownReply(restart: content.restart)
            default:
                continue
            }
            
            let replyMessage = Message(header: replyHeader, parentHeader: requestHeader, metadata: [:], content: replyContent)
            
            outMessageQueue.add(replyMessage)
        }
    }
    
    fileprivate static func execute(_ cmd: String, executionCount: Int, parentHeader: Header, metadata: [String: Any]) {
        if session.isEmpty {
            session = parentHeader.session
            
            // Sending starting status.
            sendIOPubMessage(.Status, content: Status(executionState: "starting"), parentHeader: nil)
        }
        
        sendIOPubMessage(.Status, content: Status(executionState: "busy"), parentHeader: parentHeader)
        
        let result = replWrapper.runCommand(cmd).trim()
        let content = ExecuteResult(executionCount: executionCount, data: ["text/plain": result], metadata: [:])
        
        sendIOPubMessage(.Status, content: Status(executionState: "idle"), parentHeader: parentHeader)
        
        sendIOPubMessage(.ExecuteResult, content: content, parentHeader: parentHeader)
    }
    
    fileprivate static func sendIOPubMessage(_ type: MessageType, content: Contentable, parentHeader: Header?, metadata: [String: Any] = [:]) {
        DispatchQueue.global(qos: .default).async { () -> Void in
            let header = Header(session: session, msgType: type)
            let message = Message(header: header, parentHeader: parentHeader, metadata: metadata, content: content)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "IOPubNotification"), object: message, userInfo: nil)
        }
    }
}
