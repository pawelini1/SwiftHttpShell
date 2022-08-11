import Foundation
import AnyCodable

public enum Method: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

public struct API {
    public enum APIError: Error {
        case invalidResponse(URLResponse?)
        case responseFailure(HTTPURLResponse, Data?)
        case missingData
        case jsonDecodingFailed(Error)
    }
    
    static let defaultResponseHandling: (Data?, URLResponse?, Error?) throws -> Void = { data, response, error in
        if let error = error { throw error }
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse(response) }
        guard (200..<300).contains(httpResponse.statusCode) else { throw APIError.responseFailure(httpResponse, data) }
    }
    
    public let message: String
    public let request: Request
    public let onResponse: (Data?, URLResponse?, Error?) throws -> Void

    public init(message: String, request: Request) {
        self.message = message
        self.request = request
        self.onResponse = { data, response, error in
            try API.defaultResponseHandling(data, response, error)
        }
    }
    
    public init(message: String, request: Request, onResponse: @escaping (Data?, URLResponse?, Error?) throws -> Void) {
        self.message = message
        self.request = request
        self.onResponse = onResponse
    }
    
    public init<T: Decodable>(message: String, request: Request, expecting: T.Type, onObject: @escaping (T) throws -> Void) {
        self.message = message
        self.request = request
        self.onResponse = { data, response, error in
            try API.defaultResponseHandling(data, response, error)
            guard let data = data else { throw APIError.missingData }
            do {
                let object = try data.json(ofType: T.self)
                try onObject(object)
            } catch {
                throw APIError.jsonDecodingFailed(error)
            }
        }
    }
}

public struct Request {
    public let method: Method
    public let url: URL
    public let payload: AnyCodable?
    public let headers: [String: String]

    public init<C: Codable>(url: URL, method: Method = .get, headers: [String: String] = [:], payload: C?) {
        self.method = method
        self.url = url
        self.payload = payload.flatMap { AnyCodable($0) }
        self.headers = headers
    }
    
    public func urlRequest() throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach {
            if request.allHTTPHeaderFields == nil { request.allHTTPHeaderFields = [:] }
            request.allHTTPHeaderFields?[$0.key] = $0.value
        }
        try payload.flatMap { payload in
            request.httpBody = try JSONEncoder().encode(payload)
        }
        return request
    }
}

extension Data {
    static var jsonDecoder = JSONDecoder()

    func json<T: Decodable>(ofType type: T.Type) throws -> T {
        try Data.jsonDecoder.decode(type, from: self)
    }
}
