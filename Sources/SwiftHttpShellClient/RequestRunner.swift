import Foundation

public struct RequestRunner {
    public enum RequestRunnerError: Error {
        case connectionError(Error)
        case notHTTPResponse(URLResponse?)
        case missingData
        case requestFailure(Int)
        case invalidResponseData(Data?)
    }

    public init() {}
    
    public func codable<ResponseType: Decodable>(for request: URLRequest, jsonDecoder: JSONDecoder = .init()) throws -> ResponseType {
        guard let data = try runRequest(for: request) else { throw RequestRunnerError.missingData }
        return try data.asCodable(jsonDecoder: jsonDecoder)
    }
    
    public func data(for request: URLRequest) throws -> Data {
        guard let data = try runRequest(for: request) else { throw RequestRunnerError.missingData }
        return data
    }
}

private extension RequestRunner {
    func runRequest(for request: URLRequest) throws -> Data? {
        let result = URLSession.shared.synchronousDataTask(with: request)
        if let error = result.error {
            throw RequestRunnerError.connectionError(error)
        }
        guard let httpResponse = result.httpResponse else {
            throw RequestRunnerError.notHTTPResponse(result.response)
        }
        guard httpResponse.statusCode == .OK else {
            throw RequestRunnerError.requestFailure(httpResponse.statusCode)
        }
        return result.data
    }
}

