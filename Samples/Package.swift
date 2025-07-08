// swift-tools-version: 6.1

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
        .package(name: "SDL3", path: "../Dependencies/SDL3"),
        .package(name: "Sedulous", path: "../Framework"),
    ],
    targets: [
        .executableTarget(
            name: "Sandbox",
            dependencies: [
                "SDL3",
                .product(name: "SedulousRuntime", package: "Sedulous"), 
                .product(name: "SedulousPlatformSDL3", package: "Sedulous"),
                .product(name: "SedulousRenderer", package: "Sedulous"),
                .product(name: "SedulousGeometry", package: "Sedulous"),
            ],
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
    ]
)