//
//  Message.swift
//  iSwiftCore
//
//  Created by Jin Wang on 19/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

enum MessageType: String {
    case KernelInfoRequest = "kernel_info_request"
    case KernelInfoReply = "kernel_info_reply"
    case ExecuteRequest = "execute_request"
    case ExecuteReply = "execute_reply"
    case HistoryRequest = "history_request"
    case HistoryReply = "history_reply"
    case CompleteRequest = "complete_request"
    case CompleteReply = "complete_reply"
    case IsCompleteRequest = "is_complete_request"
    case IsCompleteReply = "is_complete_reply"
    case ExecuteResult = "execute_result"
    case ExecuteInput = "execute_input"
    case Status = "status"
    case ShutdownRequest = "shutdown_request"
    case ShutdownReply = "shutdown_reply"

    var replyType: MessageType? {
        return MessageType(rawValue: self.rawValue.replacingOccurrences(of: "request", with: "reply"))
    }
}

#if os(Linux)
    class Message {
        static let Delimiter = "<IDS|MSG>"
        static let EmptyDic: [String: Any] = [:]
        
        let idents: [Data]
        
        /// The message header contains a pair of unique identifiers for the
        /// originating session and the actual message id, in addition to the
        /// username for the process that generated the message.  This is useful in
        /// collaborative settings where multiple users may be interacting with the
        /// same kernel simultaneously, so that frontends can label the various
        /// messages in a meaningful way.
        let header: Header
        
        /// In a chain of messages, the header from the parent is copied so that
        /// clients can track where messages come from.
        let parentHeader: Header?
        
        /// Any metadata associated with the message.
        let metadata: [String: Any]
        
        /// The actual content of the message must be a dict, whose structure
        /// depends on the message type.
        let content: Contentable
        
        let extraBlobs: [Data]
        
        init(idents: [Data],
             header: Header,
             parentHeader: Header?,
             metadata: [String: Any],
             content: Contentable,
             extraBlobs: [Data]) {
            self.idents = idents
            self.header = header
            self.parentHeader = parentHeader
            self.metadata = metadata
            self.content = content
            self.extraBlobs = extraBlobs
        }
    }
#else
    struct Message {
        static let Delimiter = "<IDS|MSG>"
        static let EmptyDic: [String: Any] = [:]
        
        let idents: [Data]
        
        /// The message header contains a pair of unique identifiers for the
        /// originating session and the actual message id, in addition to the
        /// username for the process that generated the message.  This is useful in
        /// collaborative settings where multiple users may be interacting with the
        /// same kernel simultaneously, so that frontends can label the various
        /// messages in a meaningful way.
        let header: Header
        
        /// In a chain of messages, the header from the parent is copied so that
        /// clients can track where messages come from.
        let parentHeader: Header?
        
        /// Any metadata associated with the message.
        let metadata: [String: Any]
        
        /// The actual content of the message must be a dict, whose structure
        /// depends on the message type.
        let content: Contentable
        
        let extraBlobs: [Data]
    }
#endif
