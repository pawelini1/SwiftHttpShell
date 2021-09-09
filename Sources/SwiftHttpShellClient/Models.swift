import Foundation

public typealias ProcessIdentifer = String

public protocol Response {
    var output: String { get }
}

public struct ProcessResponse: Response, Decodable {
    public var output: String { "Process with identifer '\(identifer)' started." }
    
    public let identifer: ProcessIdentifer
    
    public init(identifer: ProcessIdentifer) {
        self.identifer = identifer
    }
}

public struct OutputResponse: Response, Decodable {
    public let output: String
    
    public init(output: String) {
        self.output = output
    }
}

public struct MultiResponse: Response {
    public var output: String {
        responses.map { $0.output }.joined(separator: "\n")
    }
    
    public let responses: [Response]
    
    public init(responses: [Response]) {
        self.responses = responses
    }
}

public struct FileResponse: Response {
    public var output: String { "File at path '\(filePath)' was downloaded." }
    
    public let filePath: String
    
    public init(filePath: String) {
        self.filePath = filePath
    }
}
