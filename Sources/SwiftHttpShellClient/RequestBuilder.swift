import Foundation

public struct RequestBuilder {
    private let jsonEncoder = JSONEncoder()
    private let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
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
