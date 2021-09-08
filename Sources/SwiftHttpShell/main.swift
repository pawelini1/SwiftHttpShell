import Foundation
import ArgumentParser
import Files
import Swifter
import Rainbow
import Promises

struct SwiftHttpShell: ParsableCommand {
    struct Start: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Starts the server.")
        
        @Option(help: "A port for the server")
        var port: in_port_t = 8888
        
        mutating func run() {
            do {
                let server = ShellHttpServer()
                try server.start(port, forceIPv4: true)
                print("SwiftHttpShell server has started. Use http://localhost:\(port) ...".cyan)
                RunLoop.main.run()
            } catch {
                Self.exitWithMessage(for: error)
            }
        }
    }
    
    static var configuration = CommandConfiguration(
        commandName: "swift-http-shell",
        abstract: "A utility for running shell commands through HTTP API.",
        version: "1.0.0",
        subcommands: [Start.self]
    )
}

private extension ParsableCommand {
    static func exitWithMessage(for error: Error? = nil) -> Never {
        print("SwiftHTTPShell finished with an error...".red)
        exit(withError: error)
    }
    
    static func exitWithSuccess() {
        print("SwiftHTTPShell finished successfully...".green)
        exit()
    }
}

DispatchQueue.promises = DispatchQueue.global(qos: .background)

SwiftHttpShell.main()
