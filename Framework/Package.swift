// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Sedulous",
    products: [
        .library(name: "SedulousCore", targets: ["SedulousCore"]),
        .library(name: "SedulousFoundation", targets: ["SedulousFoundation"]),
        .library(name: "SedulousPlatform", targets: ["SedulousPlatform"]),
        .library(name: "SedulousPlatformSDL3", targets: ["SedulousPlatformSDL3"]),
        .library(name: "SedulousRuntime", targets: ["SedulousRuntime"]),
    ],
    dependencies: [
        .package(name: "SDL3", path: "../Dependencies/SDL3"),
    ],
    targets: [
        .target(name: "SedulousCore", dependencies: ["SedulousFoundation"], path: "Sources/Core"),
        .target(name: "SedulousFoundation", path: "Sources/Foundation"),
        .target(name: "SedulousPlatform", path: "Sources/Platform"),
        .target(name: "SedulousPlatformSDL3", 
            dependencies: [
                "SedulousPlatform",
                "SDL3"
            ],
            path: "Sources/PlatformSDL3",
            cSettings: [
                .headerSearchPath("../Dependencies/SDL3/Sources/SDL3/include"),
                .define("SDL_MAIN_HANDLED")
            ],
            swiftSettings: [
                .unsafeFlags(["-I", "../Dependencies/SDL3/Sources/SDL3/include"])
            ],
            linkerSettings: [
                .unsafeFlags(["-L", "../Dependencies/SDL3/Sources/SDL3/lib/x64"]),
                .linkedLibrary("SDL3"),
            ]
        ),
        .target(name: "SedulousRuntime", path: "Sources/Runtime"),
    ]
)