// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Samples",
    products: [
        .executable(
            name: "Sandbox",
            targets: ["Sandbox"]
        ),
    ],
    dependencies: [
        .package(path: "../Dependencies/SDL3")
    ],
    targets: [
        .executableTarget(
            name: "Sandbox",
            dependencies: ["SDL3"]
        ),
    ]
)