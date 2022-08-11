// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftHttpShell",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .executable(name: "swift-http-shell", targets: ["SwiftHttpShell"]),
        .library(name: "SwiftHttpShellClient", targets: ["SwiftHttpShellClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/JohnSundell/Files", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.0")),
        .package(name: "Swifter", url: "https://github.com/httpswift/swifter.git", .upToNextMinor(from: "1.5.0")),
        .package(name: "Promises", url: "https://github.com/google/promises.git", .upToNextMajor(from: "2.0.0")),
        .package(name: "AnyCodable", url: "https://github.com/Flight-School/AnyCodable", .upToNextMajor(from: "0.6.0"))
    ],
    targets: [
        .target(
            name: "SwiftHttpShell",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Files", package: "Files"),
                .product(name: "ShellOut", package: "ShellOut"),
                .product(name: "Rainbow", package: "Rainbow"),
                "Swifter",
                "Promises"
            ]),
        .target(
            name: "SwiftHttpShellClient",
            dependencies: [
                "Promises",
                "AnyCodable"
            ])
    ]
)
