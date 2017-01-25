//
//  Shell.swift
//  iSwift
//
//  Created by Jin Wang on 13/9/16.
//
//

import Foundation
import Dispatch
import CoreFoundation

private let MAX_DATA_SIZE = 1024

enum TaskError: Swift.Error {
    case generalError(String)
}

class Printer {
    static func print(_ msg: String) {
        Logger.info.print(msg)
    }
}

class Shell {
    static let dataAvailableNotification = NSNotification.Name(rawValue: "TASK.DATA.AVAILABLE")
    static let didTerminateNotification = NSNotification.Name(rawValue: "TASK.DID.TERMINATE")
    
    var launchPath: String = ""
    var echoOn: Bool = false
    var availableData = Data()
    
    private var fdMaster: Int32 = -1
    private var fdSlave: Int32 = -1
    private var pid: pid_t = -1
    private var hasLaunched: Bool {
        return pid > 0
    }
    
    init() {
        // Create a pipe with two file descriptor. The fdMaster will be used on the child process side to communicate with the launched process.
        // Child process is the one that we can control.
        let rc = openpty(&fdMaster, &fdSlave, nil, nil, nil)
        
        if rc != 0 {
            fatalError(NSPOSIXErrorDomain)
        }
        
        fcntl(fdMaster, F_SETFD, FD_CLOEXEC)
        fcntl(fdSlave, F_SETFD, FD_CLOEXEC)
        
        if !echoOn {
            try? turnOffEcho(fdMaster)
        }
    }
    
    func launch() throws {
        pid = pid_t()
        
        // Tell the launched process to use fdSlave as stdin & stdout. So that we can send/receive messages from fdMaster side.
        #if os(OSX) || os(iOS)
            var fileActions: posix_spawn_file_actions_t? = nil
        #else
            var fileActions: posix_spawn_file_actions_t = posix_spawn_file_actions_t()
        #endif
        posix(posix_spawn_file_actions_init(&fileActions))
        defer { posix_spawn_file_actions_destroy(&fileActions) }
        
        posix(posix_spawn_file_actions_adddup2(&fileActions, fdSlave, STDIN_FILENO))
        posix(posix_spawn_file_actions_adddup2(&fileActions, fdSlave, STDOUT_FILENO))
        posix(posix_spawn_file_actions_adddup2(&fileActions, fdSlave, STDERR_FILENO))
        
        let args = [launchPath]
        
        let argv : UnsafeMutablePointer<UnsafeMutablePointer<Int8>?> = args.withUnsafeBufferPointer {
            let array : UnsafeBufferPointer<String> = $0
            let buffer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: array.count + 1)
            buffer.initialize(from: array.map { $0.withCString(strdup) })
            buffer[array.count] = nil
            return buffer
        }
        
        // Start the process.
        posix(posix_spawn(&pid, launchPath.cString(using: String.Encoding.utf8), &fileActions, nil, argv, nil))
        
        if pid < 0 {
            throw TaskError.generalError("Invalid pid.")
        }
        
        Printer.print("Launch successed.")
    }
    
    func waitUntilExit() {
        checkLaunched()
        
        var status: Int32 = 0
        var waitResult: Int32 = 0
        repeat {
            waitResult = waitpid(pid, &status, 0)
        } while ( (waitResult == -1) && (errno == EINTR) )
        
        Printer.print("Child process exited with status \(status).")
    }
    
    func waitForDataInBackgroundAndNotify(forModes modes: [RunLoopMode]) {
        assert(!modes.isEmpty, "empty modes are not allowed.")
        
        DispatchQueue.global().async {
            
            Printer.print("Waiting for data...")
            
            let data = UnsafeMutableRawPointer.allocate(bytes: MAX_DATA_SIZE, alignedTo: MemoryLayout<UInt8>.alignment)
            var actualSize = read(self.fdMaster, data, MAX_DATA_SIZE)
            var finalData = Data()
            while actualSize >= 0 {
                if actualSize == 0 {
                    Printer.print("End of the file?!")
                    break
                }
                
                finalData.append(Data(bytesNoCopy: data, count: actualSize, deallocator: .none))
                
                if actualSize < MAX_DATA_SIZE {
                    // Seems enough.
                    break
                }
                
                actualSize = read(self.fdMaster, data, MAX_DATA_SIZE)
            }
            
            self.availableData = finalData
            
            if #available(OSX 10.12, *) {
                RunLoop.current.perform(inModes: modes, block: { [weak self] in
                    self?.notifyDataAvailable()
                })
            } else {
                
                #if os(Linux)
                RunLoop.current.perform(inModes: modes, block: { [weak self] in
                    self?.notifyDataAvailable()
                })
                #else
                RunLoop.current.perform(#selector(Shell.notifyDataAvailable), target: self, argument: nil, order: Int.max, modes: modes)
                #endif
            }
            
            RunLoop.current.run()
        }
    }
    
    @objc private func notifyDataAvailable() {
        // Got enough info, let's notify.
        NotificationCenter.default.post(name: Shell.dataAvailableNotification, object: self, userInfo: nil)
        
        CFRunLoopStop(RunLoop.current.getCFRunLoop())
    }
    
    func writeWith(_ data: Data) {
        Printer.print("Writing to console...AAAAAAA")
        
        checkLaunched()
        
        Printer.print("Writing to console...")
        
        let size = data.count
        let dataPtr: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        data.copyBytes(to: dataPtr, count: size)
        let rawPtr = UnsafeRawPointer(dataPtr)
        write(fdMaster, rawPtr, size)
    }
    
    func terminate() {
        // Kill the child process.
        Printer.print("Killed child process with result \(kill(pid, SIGINT)).")
        
        NotificationCenter.default.post(name: Shell.didTerminateNotification, object: self, userInfo: nil)
    }
    
    private func checkLaunched() {
        guard hasLaunched else { fatalError("The task has not been launched.") }
    }
    
    private func posix(_ code: Int32) {
        switch code {
        case 0: return
        case EBADF: fatalError("POSIX command failed with error: \(code) -- EBADF")
        default: fatalError("POSIX command failed with error: \(code)")
        }
    }
    
    private func turnOffEcho(_ fd: Int32) throws {
        // Code from http://man7.org/tlpi/code/online/book/tty/no_echo.c.html
        
        /* Retrieve current terminal settings, turn echoing off */
        var tp = termios()
        
        if (tcgetattr(fd, &tp) == -1) {
            throw TaskError.generalError("tcgetattr error.")
        }
        
        /* ECHO off, other bits unchanged */
        #if os(Linux)
            tp.c_lflag &= ~UInt32(ECHO);
        #else
            tp.c_lflag &= ~UInt(ECHO);
        #endif
        
        if (tcsetattr(fd, TCSAFLUSH, &tp) == -1) {
            throw TaskError.generalError("tcsetattr error.")
        }
    }
}
