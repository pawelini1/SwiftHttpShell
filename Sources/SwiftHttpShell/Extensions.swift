import Foundation
import Swifter

extension HttpResponseBody {
    static func error(_ error: Error) -> HttpResponseBody {
        .json([
            "error": String(describing: error).javaScriptEscapedString  
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

extension String {
    var javaScriptEscapedString: String {
        // Because JSON is not a subset of JavaScript, the LINE_SEPARATOR and PARAGRAPH_SEPARATOR unicode
        // characters embedded in (valid) JSON will cause the webview's JavaScript parser to error. So we
        // must encode them first. See here: http://timelessrepo.com/json-isnt-a-javascript-subset
        // Also here: http://media.giphy.com/media/wloGlwOXKijy8/giphy.gif
        let str = self.replacingOccurrences(of: "\u{2028}", with: "\\u2028")
                      .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
        // Because escaping JavaScript is a non-trivial task (https://github.com/johnezang/JSONKit/blob/master/JSONKit.m#L1423)
        // we proceed to hax instead:
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode([str])
            let encodedString = String(decoding: data, as: UTF8.self)
            return String(encodedString.dropLast().dropFirst())
        } catch {
            return self
        }
    }
}
