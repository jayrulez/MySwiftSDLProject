// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Sedulous",
    products: [
        .library(name: "SedulousEngine", targets: ["SedulousEngine"]),
        .library(name: "SedulousJobs", targets: ["SedulousJobs"]),
        .library(name: "SedulousResources", targets: ["SedulousResources"]),
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
        .target(name: "SedulousEngine", dependencies: ["SedulousFoundation", "SedulousJobs", "SedulousResources"], path: "Sources/Engine"),
        .target(name: "SedulousJobs", path: "Sources/Jobs"),
        .target(name: "SedulousResources", dependencies: ["SedulousJobs"], path: "Sources/Resources"),
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
                "SedulousEngine",
            ], 
            path: "Sources/Audio"),
        .target(name: "SedulousAudioSDL3",
            dependencies: [
                "SedulousEngine",
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
                "SedulousEngine",
            ], 
            path: "Sources/Input"),
        .target(name: "SedulousRenderer",
            dependencies: [
                "SedulousEngine",
            ], 
            path: "Sources/Renderer"),
        .target(name: "SedulousRuntime",
            dependencies: [
                "SedulousPlatform",
                "SedulousEngine",
                "SedulousAudio",
                "SedulousAudioSDL3",
                "SedulousInput",
                "SedulousRenderer",
            ], 
            path: "Sources/Runtime"),
    ]
)