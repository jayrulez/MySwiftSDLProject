// swift-tools-version:6.1
import PackageDescription

let package: Package = Package(
    name: "SDL3",
    products: [
        .library(name: "SDL3", targets: ["SDL3"])
    ],
    targets: [
        .systemLibrary(
            name: "SDL3",
            path: "Sources/SDL3",
            pkgConfig: nil,
            providers: [],
        ),
    ]
)