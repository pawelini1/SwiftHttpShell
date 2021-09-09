import Foundation

public extension String {
    var escapingSpaces: String {
        return replacingOccurrences(of: " ", with: "\\ ")
    }
}

extension URL {
    static func localhost(port: UInt16 = 8888) -> URL {
        URL(string: "http://localhost:\(port)/")!
    }
}

extension Int {
    static var OK: Int { 200 }
}

extension Data {
    enum DataError: Error {
        case stringConvertionFailure(Data)
    }
    
    func asCodable<Type: Decodable>(jsonDecoder: JSONDecoder) throws -> Type {
        try jsonDecoder.decode(Type.self, from: self)
    }
    
    func asString() throws -> String {
        guard let string = String(data: self, encoding: .utf8) else { throw DataError.stringConvertionFailure(self) }
        return string
    }
}

extension URLSession {
    struct DataTaskResult {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        
        var httpResponse: HTTPURLResponse? { response as? HTTPURLResponse }
    }
    
    func synchronousDataTask(with urlRequest: URLRequest) -> DataTaskResult {
        var obj: DataTaskResult!
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = dataTask(with: urlRequest) { data, response, error in
            obj = DataTaskResult(data: data, response: response, error: error)
            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return obj
    }
}
