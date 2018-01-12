// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CSV",
    products: [
        .library(name: "CSV", targets: ["CSV"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/bits.git", .exact("1.1.0"))
    ],
    targets: [
        .target(name: "CSV", dependencies: ["Bits"]),
        .testTarget(name: "CSVTests", dependencies: ["CSV"]),
    ]
)
