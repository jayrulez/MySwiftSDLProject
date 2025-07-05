// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SDL3",
    products: [
        .library(
            name: "SDL3",
            targets: ["SDL3"]
        ),
    ],
    targets: [
        .target(
            name: "SDL3",
            path: "Sources/SDL3",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("include"),
            ],
            linkerSettings: [
                .linkedLibrary("SDL3"),
                .unsafeFlags(["-L", "Sources/SDL3/lib/x64"]),
            ]
        ),
    ]
)