// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CSV",
    products: [
        .library(name: "CSV", targets: ["CSV"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0-rc")
    ],
    targets: [
        .target(name: "CSV", dependencies: ["Bits"]),
        .testTarget(name: "CSVTests", dependencies: ["CSV"]),
    ]
)
