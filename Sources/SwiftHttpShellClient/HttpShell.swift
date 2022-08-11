import Foundation
import Promises
import XCTest

public class HttpShell {
    public static func localhost(port: UInt16) -> HttpShell {
        return HttpShell(baseUrl: .localhost(port: port))
    }
    
    private let runner = RequestRunner()
    private let builder: RequestBuilder
    
    public init(baseUrl: URL) {
        self.builder = RequestBuilder(baseURL: baseUrl)
    }
    
    public func shell(_ command: Command) throws -> Response {
        switch command.type {
        case .shell(command: let cmd, completion: let completion):
            return try XCTContext.runActivity(named: command.message) { activity in
                let output = try runCodableRequest(.shell, parameters: [
                    "command": cmd
                ]) as OutputResponse
                try completion?(output)
                return output
            }
        case .start(command: let cmd, identifer: let identifer):
            return try XCTContext.runActivity(named: command.message) { activity in
                return try runCodableRequest(.start, parameters: [
                    "command": cmd,
                    "id": identifer
                ].compactMapValues { $0 }) as ProcessResponse
            }
        case .finish(identifer: let identifer):
            return try XCTContext.runActivity(named: command.message) { activity in
                return try runCodableRequest(.finish, parameters: [
                    "id": identifer
                ]) as OutputResponse
            }
        case .multi(commands: let commands):
            return try XCTContext.runActivity(named: command.message) { activity in
                return try MultiResponse(responses: commands.map { try self.shell($0) })
            }
        case .file(atPath: let path, completion: let completion):
            return try XCTContext.runActivity(named: command.message) { activity in
                let data = try runDataRequest(.file, parameters: [
                    "path": path
                ])
                try completion(data)
                return FileResponse(filePath: path)
            }
        }
        
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
    case start
    case finish
    case file
}
