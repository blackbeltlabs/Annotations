// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Annotations",
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
            dependencies: [])
    ]
)
