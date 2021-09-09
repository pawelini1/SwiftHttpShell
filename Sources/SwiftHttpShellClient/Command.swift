import Foundation

public enum CommandType {
    case shell(command: String)
    case start(command: String, identifer: ProcessIdentifer?)
    case finish(identifer: ProcessIdentifer)
    case multi(commands: [Command])
    case file(atPath: String, completion: (Data) throws -> Void)
}

public struct Command {
    public let message: String
    public let type: CommandType
    
    public init(type: CommandType, message: String) {
        self.type = type
        self.message = message
    }
}
