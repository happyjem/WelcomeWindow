// swift-tools-version: 6.0.0

import PackageDescription

let package = Package(
    name: "WelcomeWindow",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "WelcomeWindow",
            targets: ["WelcomeWindow"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/lukepistrol/SwiftLintPlugin",
            from: "0.2.2"
        )
    ],
    targets: [
        .target(
            name: "WelcomeWindow",
            plugins: [
                .plugin(name: "SwiftLint", package: "SwiftLintPlugin")
            ]
        ),
        .testTarget(name: "WelcomeWindowTests", dependencies: ["WelcomeWindow"])
    ]
)
