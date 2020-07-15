// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DependencyInjection",
    products: [
        .library(
            name: "DependencyInjection",
            targets: ["DependencyInjection"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", .branch("master"))
    ],
    targets: [
        .target(
            name: "DependencyInjection",
            dependencies: []
        ),
        .testTarget(
            name: "DependencyInjectionTests",
            dependencies: ["DependencyInjection"]
        )
    ]
)
