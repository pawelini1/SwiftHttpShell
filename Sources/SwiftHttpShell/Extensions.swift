import Foundation
import Swifter

extension HttpResponseBody {
    static func error(_ error: Error) -> HttpResponseBody {
        .json([
            "error": error
        ])
    }
    
    static func processIdentifer(_ identifer: String) -> HttpResponseBody {
        .json([
            "identifer": identifer
        ])
    }
    
    static func output(_ output: String) -> HttpResponseBody {
        .json([
            "output": output
        ])
    }
}

extension HttpRequest {
    public func parseJson(with decoder: JSONDecoder) -> [(String, String)] {
        guard let contentTypeHeader = headers["content-type"] else {
            return []
        }
        let contentTypeHeaderTokens = contentTypeHeader.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let contentType = contentTypeHeaderTokens.first, contentType == "application/json" else {
            return []
        }
        guard let dictionary = try? decoder.decode([String: String].self, from: Data(body)) else {
            return []
        }
        return dictionary.map { $0 }
    }
}
