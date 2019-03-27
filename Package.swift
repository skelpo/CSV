// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CSV",
    products: [
        .library(name: "CSV", targets: ["CSV"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/core.git", from: "3.4.3"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.3.0")
    ],
    targets: [
        .target(name: "CSV", dependencies: ["Bits", "Debugging", "Async", "Core"]),
        .testTarget(name: "CSVTests", dependencies: ["CSV", "Random"]),
    ]
)
