import Foundation

public struct RequestBuilder {
    private let jsonEncoder = JSONEncoder()
    private let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public func shell(command: String) throws -> URLRequest {
        try request(endpoint: "shell", method: "POST", params: [
            "command": command
        ])
    }
    
    public func process(command: String) throws -> URLRequest {
        try request(endpoint: "process", method: "POST", params: [
            "command": command
        ])
    }
    
    public func terminate(id: String) throws -> URLRequest {
        try request(endpoint: "terminate", method: "POST", params: [
            "id": id
        ])
    }
    
    public func file(path: String) throws -> URLRequest {
        try request(endpoint: "file", method: "POST", params: [
            "path": path
        ])
    }
    
    public func request<Parameters: Encodable>(endpoint: String, method: String, params: Parameters) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.timeoutInterval = 300
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try jsonEncoder.encode(params)
        return request
    }
}
