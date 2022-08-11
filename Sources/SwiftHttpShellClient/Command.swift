import Foundation

public enum CommandType {
    case shell(command: String, completion: ((OutputResponse) throws -> Void)?)
    case start(command: String, identifer: ProcessIdentifer?)
    case finish(identifer: ProcessIdentifer)
    case multi(commands: [Command])
    case file(atPath: String, completion: (Data) throws -> Void)
    
    public static func shell(command: String) -> CommandType {
        .shell(command: command, completion: nil)
    }
}

public struct Command {
    public let message: String
    public let type: CommandType
    
    public init(type: CommandType, message: String) {
        self.type = type
        self.message = message
    }
}
