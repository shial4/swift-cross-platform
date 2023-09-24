// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logic",
    
    products: [
        // Shared business logic
        .library(
            name: "Logic",
            targets: ["Logic"]),

        // Application
        .executable(
            name: "App",
            targets: ["App"]),
    ],

    dependencies: [
        .package(url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.4.0")
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Logic"),
        .testTarget(
            name: "LogicTests",
            dependencies: ["Logic"]),

        .target(
            name: "App",
            dependencies: ["Logic"]),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"]),
    ]
)
