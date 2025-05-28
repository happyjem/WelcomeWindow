// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WelcomeWindow",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WelcomeWindow",
            targets: ["WelcomeWindow"]),
    ],
    dependencies: [
        // SwiftLint
        .package(
            url: "https://github.com/lukepistrol/SwiftLintPlugin",
            from: "0.2.2"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WelcomeWindow"
        ),
        // Tests for the source editor
        .testTarget(
            name: "WelcomeWindowTests",
            dependencies: [
                "WelcomeWindow",
            ]
        ),
    ]
)
