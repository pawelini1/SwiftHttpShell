import Foundation

public struct Command: Encodable {
    private let command: String
    
    public init(command: String) {
        self.command = command
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(command)
    }
}

extension Command: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(command: value)
    }
}
