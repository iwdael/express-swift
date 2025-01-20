// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Express",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Express",
            targets: ["Express"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.79.0")),
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.6.2")),
        .package(url: "https://github.com/apple/swift-nio-ssl", .upToNextMajor(from: "2.29.0")),
        .package(url: "https://github.com/apple/swift-nio-http2", .upToNextMajor(from: "1.35.0")),
    ],
    targets: [
        .target(
            name: "Express",	
            dependencies: [
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ExpressTests",
            dependencies: ["Express"]
        ),
    ]
)
