// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Annotations",
    defaultLocalization: "en",
    platforms: [.macOS("10.15")],
    products: [
        .library(
            name: "Annotations",
            type: .dynamic,
            targets: ["Annotations"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Annotations",
            dependencies: [],
            resources: [.process("Resources")])
    ]
)
