import Foundation
import Promises

class ProcessStorage {
    enum ProcessStorageError: Error {
        case noSuchProcess(ProcessIdentifier)
    }
    
    private let accesssQueue: DispatchQueue
    private var processes: [ProcessIdentifier: Process] = [:]
    
    init(accesssQueue: DispatchQueue = .init(label: "com.SwiftHttpShell.ProcessStorage")) {
        self.accesssQueue = accesssQueue
    }
    
    func newProcess() -> Promise<Process> {
        return Promise(on: accesssQueue, { () -> Process in
            let process = Process()
            self.processes[process.identifer] = process
            return process
        })
    }
        
    func process(with identifer: ProcessIdentifier) -> Promise<Process> {
        return Promise(on: accesssQueue, { () -> Process in
            guard let process = self.processes[identifer] else {
                throw ProcessStorageError.noSuchProcess(identifer)
            }
            return process
        })
    }
}
