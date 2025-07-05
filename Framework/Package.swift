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
        .library(name: "SedulousAudio", targets: ["SedulousAudio"]),
        .library(name: "SedulousAudioSDL3", targets: ["SedulousAudioSDL3"]),
        .library(name: "SedulousInput", targets: ["SedulousInput"]),
        .library(name: "SedulousRenderer", targets: ["SedulousRenderer"]),
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
            ],
            swiftSettings: [
                .unsafeFlags(["-I", "../Dependencies/SDL3/Sources/SDL3/include"])
            ],
            linkerSettings: [
                .unsafeFlags(["-L", "../Dependencies/SDL3/Sources/SDL3/lib/x64"]),
                .linkedLibrary("SDL3"),
            ]
        ),
        .target(name: "SedulousAudio",
            dependencies: [
                "SedulousCore",
            ], 
            path: "Sources/Audio"),
        .target(name: "SedulousAudioSDL3",
            dependencies: [
                "SedulousCore",
                "SedulousAudio",
                "SDL3",
            ], 
            path: "Sources/AudioSDL3",
            cSettings: [
                .headerSearchPath("../Dependencies/SDL3/Sources/SDL3/include"),
            ],
            swiftSettings: [
                .unsafeFlags(["-I", "../Dependencies/SDL3/Sources/SDL3/include"])
            ],
            linkerSettings: [
                .unsafeFlags(["-L", "../Dependencies/SDL3/Sources/SDL3/lib/x64"]),
                .linkedLibrary("SDL3"),
            ]
        ),
        .target(name: "SedulousInput",
            dependencies: [
                "SedulousCore",
            ], 
            path: "Sources/Input"),
        .target(name: "SedulousRenderer",
            dependencies: [
                "SedulousCore",
            ], 
            path: "Sources/Renderer"),
        .target(name: "SedulousRuntime",
            dependencies: [
                "SedulousPlatform",
                "SedulousCore",
                "SedulousAudio",
                "SedulousAudioSDL3",
                "SedulousInput",
                "SedulousRenderer",
            ], 
            path: "Sources/Runtime"),
    ]
)