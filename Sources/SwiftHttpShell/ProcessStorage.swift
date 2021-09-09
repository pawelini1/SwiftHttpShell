import Foundation
import Promises

class ProcessStorage {
    enum ProcessStorageError: Error {
        case noSuchProcess(ProcessIdentifier)
        case processAlreadyExists(ProcessIdentifier)
    }
    
    private let accesssQueue: DispatchQueue
    private var processes: [ProcessIdentifier: Process] = [:]
    
    init(accesssQueue: DispatchQueue = .init(label: "com.SwiftHttpShell.ProcessStorage")) {
        self.accesssQueue = accesssQueue
    }
    
    func newProcess(with identifer: ProcessIdentifier? = nil) -> Promise<Process> {
        return Promise(on: accesssQueue, { () -> Process in
            func addProcess(_ process: Process) -> Process {
                self.processes[process.identifer] = process
                return process
            }
            guard let identifer = identifer else {
                return addProcess(Process())
            }
            guard let _ = self.processes[identifer] else {
                return addProcess(Process(identifer: identifer))
            }
            throw ProcessStorageError.processAlreadyExists(identifer)
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
    
    func removeProcess(with identifer: ProcessIdentifier) -> Promise<Void> {
        return Promise(on: accesssQueue, { () -> Void in
            guard let _ = self.processes[identifer] else {
                throw ProcessStorageError.noSuchProcess(identifer)
            }
            self.processes.removeValue(forKey: identifer)
        })
    }
}
