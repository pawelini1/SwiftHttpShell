import Foundation

var standardError = FileHandle.standardError
var standardOutput = FileHandle.standardOutput

extension FileHandle : TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}

func logMessage(_ string: String) {
    print(string, to:&standardOutput)
}

func logError(_ string: String) {
    print(string, to:&standardError)
}

