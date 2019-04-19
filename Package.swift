// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CSV",
    products: [
        .library(name: "CSV", targets: ["CSV"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CSV", dependencies: []),
        .testTarget(name: "CSVTests", dependencies: ["CSV"]),
    ]
)
