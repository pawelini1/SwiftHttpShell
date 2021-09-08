import Foundation
import Promises

public class HttpShell {
    public static func localhost(port: UInt16) -> HttpShell {
        return HttpShell(baseUrl: .localhost(port: port))
    }
    
    private let runner = RequestRunner()
    private let builder: RequestBuilder
    
    public init(baseUrl: URL) {
        self.builder = RequestBuilder(baseURL: baseUrl)
    }
    
    @discardableResult
    public func run(_ command: Command) throws -> OutputResponse {
        try runCodableRequest(.shell, parameters: [
            "command": command
        ])
    }
    
    @discardableResult
    public func start(_ command: Command) throws -> ProcessResponse {
        try runCodableRequest(.process, parameters: [
            "command": command
        ])
    }
    
    @discardableResult
    public func finish(_ identifer: ProcessIdentifer) throws -> OutputResponse {
        try runCodableRequest(.terminate, parameters: [
            "id": identifer
        ])
    }
    
    public func file(_ path: String) throws -> Data {
        try runDataRequest(.file, parameters: [
            "path": path
        ])
    }
}

private extension HttpShell {
    func runCodableRequest<Type: Decodable, Parameters: Encodable>(_ endpoint: Endpoint, method: String = "POST", parameters: Parameters) throws -> Type {
        return try runner.codable(for: builder.request(endpoint: endpoint.rawValue, method: method, params: parameters))
    }
    
    func runDataRequest<Parameters: Encodable>(_ endpoint: Endpoint, method: String = "POST", parameters: Parameters) throws -> Data {
        return try runner.data(for: builder.request(endpoint: endpoint.rawValue, method: method, params: parameters))
    }
}

private enum Endpoint: String {
    case shell
    case process
    case terminate
    case file
}
