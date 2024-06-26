// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenAISwift",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OpenAISwift",
            targets: ["OpenAISwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession.git", from: "1.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OpenAISwift", dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ], plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]),
        .testTarget(
            name: "OpenAISwiftTests",
            dependencies: ["OpenAISwift"]),

    ]
)
