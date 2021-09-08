import Foundation
import Promises
import ShellOut

typealias ProcessIdentifier = String

class Process {
    enum ProcessError: Error {
        case processNotRunning
    }
    
    let identifer: ProcessIdentifier
    private let process: Foundation.Process
    private var onFinish: Promise<String>?
    
    init(identifer: ProcessIdentifier = UUID().uuidString, process: Foundation.Process = .init()) {
        self.identifer = identifer
        self.process = process
    }
    
    func run(_ command: String) -> Promise<String> {
        let onFinish = Promise<String> { [process] in
            try shellOut(to: command, process: process)
        }
        self.onFinish = onFinish
        return onFinish
    }
    
    func terminate() -> Promise<String> {
        guard let onFinish = onFinish else {
            return Promise(ProcessError.processNotRunning)
        }
        process.interrupt()
        return onFinish
    }
}
