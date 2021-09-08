import Foundation

public typealias ProcessIdentifer = String

public struct ProcessResponse: Decodable {
    public let identifer: ProcessIdentifer
}

public struct OutputResponse: Decodable {
    public let output: String
    
    public init(output: String) {
        self.output = output
    }
}
