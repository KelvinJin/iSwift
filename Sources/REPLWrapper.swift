//
//  REPLWrapper.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation

enum REPLState {
    case prompt
    case input
    case output
}

class REPLWrapper: NSObject {
    private let command: String
    private var prompt: String
    private var continuePrompt: String
    private var communicator: FileHandle!
    private var lastOutput: String = ""
    private var consoleOutput = Observable<String>("")
    private var currentTask: Task!
    
    private let runModes = [RunLoopMode.defaultRunLoopMode]
    
    init(command: String, prompt: String, continuePrompt: String) throws {
        self.command = command
        self.prompt = prompt
        self.continuePrompt = continuePrompt
        
        super.init()
        
        try launchTaskInBackground()
    }
    
    func didReceivedData(_ notification: Notification) {
        let data = communicator.availableData
        
        guard let dataStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else { return }
        
        // For every data the console gives, it can be a new prompt or a continue prompt or an actual output.
        // We'll need to deal with it accordingly.
        if dataStr.match(prompt, options: [.anchorsMatchLines]) {
            // It's a new prompt.
        } else if dataStr.match(continuePrompt, options: [.anchorsMatchLines]) {
            // It's a continue prompt. It means the console is expecting more data.
        } else {
            // It's a raw output.
        }
        
        // Sometimes, the output will contain multiline string. We can't deal with them once. We
        // need to separater them, so that the prompt is dealt in time and the raw output will be captured.
        let lines = dataStr.components(separatedBy: CharacterSet.newlines)
        
        for (index, line) in lines.enumerated() {
            guard !line.isEmpty else { continue }
            
            // Don't remember to add a new line to compensate the loss of the non last line.
            if index == lines.count - 1 && !dataStr.hasSuffix("\n") {
                consoleOutput.next(line)
            } else {
                consoleOutput.next("\(line)\n")
            }
        }
        
        communicator.waitForDataInBackgroundAndNotify(forModes: runModes as! [RunLoopMode])
    }
    
    func taskDidTerminated(_ notification: Notification) {
    }
    
    // The command might be a multiline command.
    func runCommand(_ cmd: String) -> String {
        // Clear the previous output.
        var currentOutput = ""
        
        // We'll observe the output stream and make sure all non-prompts gets recorded into output.
        
        for line in cmd.components(separatedBy: CharacterSet.newlines) {
            // Send out this line for execution.
            sendLine(line)
            
            // For each line, the console will either give back
            // an output (might empty) + an prompt or an continue
            // prompt.
            expect([prompt, continuePrompt]) { output in
                currentOutput += output
            }
        }
        
        lastOutput = currentOutput
        
        // It doesn't matter whether there's any output or not.
        // If the command triggered no output then we'll just return
        // empty string.
        return lastOutput
    }
    
    func shutdown(_ restart: Bool) throws {
        // For now, we just terminate it forcely. We should probably
        // use :quit in the future.
        currentTask.terminate()
        
        if restart {
            try launchTaskInBackground()
        }
    }
    
    private func launchTaskInBackground() throws {
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault).async { [unowned self] in
            do {
                try self.launchTask()
            } catch let e {
                Logger.critical.print(e)
            }
        }
        
        expect([prompt])
    }
    
    private func launchTask() throws {
        currentTask = Task()
        currentTask.launchPath = command
        
        communicator = try currentTask.masterSideOfPTY()
        
        NotificationCenter.default.addObserver(self, selector: #selector(REPLWrapper.didReceivedData(_:)),
            name: NSNotification.Name.NSFileHandleDataAvailable, object: nil)
        
        communicator.waitForDataInBackgroundAndNotify(forModes: runModes as! [RunLoopMode])
        
        NotificationCenter.default.addObserver(self, selector: #selector(REPLWrapper.taskDidTerminated(_:)),
            name: Task.didTerminateNotification, object: nil)
        
        currentTask.launch()
        
        currentTask.waitUntilExit()
    }
    
    private func sendLine(_ code: String) {
        // Get rid of the new line stuff which make no sense.
        var trimmedLine = code.trim()
        
        // Only one new line character is needed. And we need
        // this new line if the trimmed code is empty.
        trimmedLine += "\n"
        
        if let codeData = trimmedLine.data(using: String.Encoding.utf8) {
            communicator.write(codeData)
        }
    }
    
    private func expect(_ patterns: [String], otherHandler: (String) -> Void = { _ in }) {
        let promptSemaphore = DispatchSemaphore(value: 0)
        
        let dispose = consoleOutput.observeNew {(output) -> Void in
            for pattern in patterns where output.match(pattern) {
                promptSemaphore.signal()
                return
            }
            otherHandler(output)
        }
        
        promptSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        dispose.dispose()
    }
}
