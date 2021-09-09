import Foundation
import Swifter
import ShellOut
import Promises
import Files

class ShellHttpServer: HttpServer {
    private let storage: ProcessStorage
    private let jsonDecoder: JSONDecoder
    
    init(storage: ProcessStorage = .init(), jsonDecoder: JSONDecoder = .init()) {
        self.storage = storage
        self.jsonDecoder = jsonDecoder
        super.init()
        
        POST["/shell"] = shell(with:)
        POST["/start"] = start(with:)
        POST["/finish"] = finish(with:)
        POST["/file"] = file(with:)
    }
}

extension ShellHttpServer {
    enum ShellHttpServerError: Error, LocalizedError {
        case missingParameter(String)
        
        var errorDescription: String? {
            switch self {
            case .missingParameter(let parameter): return "Missing parameter '\(parameter)' in request's body"
            }
        }
    }
    
    func shell(with request: HttpRequest) -> HttpResponse {
        do {
            let parameters = request.parseJson(with: jsonDecoder)
            guard let command = parameters.first(where: { $0.0 == "command" })?.1 else {
                throw ShellHttpServerError.missingParameter("command")
            }
            print("Handling command: \n".cyan + command.yellow)
            let output = try shellOut(to: command)
            print("Success!".green)
            return HttpResponse.ok(.output(output))
        } catch {
            print("Failure:".red + "\(error)")
            return HttpResponse.badRequest(.error(error))
        }
    }
    
    func start(with request: HttpRequest) -> HttpResponse {
        do {
            let parameters = request.parseJson(with: jsonDecoder)
            guard let command = parameters.first(where: { $0.0 == "command" })?.1 else {
                throw ShellHttpServerError.missingParameter("command")
            }
            let identifer = parameters.first(where: { $0.0 == "id" })?.1
            print("Handling processing command: \n".cyan + command.yellow)
            let processIdentifer = try runNewProcess(for: command, with: identifer).resolveOrThrow()
            print("Processing command success with identifer: ".green + processIdentifer)
            return HttpResponse.ok(.processIdentifer(processIdentifer))
        } catch {
            print("Failure:".red + "\(error)")
            return HttpResponse.badRequest(.error(error))
        }
    }
    
    func finish(with request: HttpRequest) -> HttpResponse {
        do {
            let parameters = request.parseJson(with: jsonDecoder)
            guard let identifer = parameters.first(where: { $0.0 == "id" })?.1 else {
                throw ShellHttpServerError.missingParameter("id")
            }
            print("Terminating command [\(identifer)]: ".cyan)
            let output = try terminateProcess(with: identifer).resolveOrThrow()
            print("Terminating success!".green)
            return HttpResponse.ok(.output(output))
        } catch {
            print("Failure:".red + "\(error)")
            return HttpResponse.badRequest(.error(error))
        }
    }
    
    func file(with request: HttpRequest) -> HttpResponse {
        do {
            let parameters = request.parseJson(with: jsonDecoder)
            guard let path = parameters.first(where: { $0.0 == "path" })?.1 else {
                throw ShellHttpServerError.missingParameter("path")
            }
            print("Sending file: ".cyan + path)
            return HttpResponse.raw(200, "OK", [:]) { writer in
                try writer.write(try File(path: path).read())
            }
        } catch {
            print("Failure:".red + "\(error)")
            return HttpResponse.badRequest(.error(error))
        }
    }
}

extension ShellHttpServer {
    func runNewProcess(for command: String, with identifer: ProcessIdentifier? = nil) -> Promise<ProcessIdentifier> {
        return Promise { () -> ProcessIdentifier in
            let process = try self.storage.newProcess(with: identifer).resolveOrThrow()
            DispatchQueue.global().async {
                let _ = process.run(command)
            }
            return process.identifer
        }
    }
    
    func terminateProcess(with identifer: ProcessIdentifier) -> Promise<String> {
        return Promise { () -> String in
            let process = try self.storage.process(with: identifer).resolveOrThrow()
            let output = try process.terminate().resolveOrThrow()
            try self.storage.removeProcess(with: identifer).resolveOrThrow()
            return output
        }
    }
}
