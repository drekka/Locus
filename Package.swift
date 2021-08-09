// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Locus",
    platforms: [
        .iOS(.v14),
        .tvOS(.v11),
        .macOS(.v10_11),
    ],
    products: [
        .library(
            name: "Locus",
            targets: ["Locus"]
        ),
    ],
    dependencies: [
        .package(name: "Nimble", url: "https://github.com/quick/nimble", branch: "main"),
    ],
    targets: [
        .target(
            name: "Locus",
            dependencies: [
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "LocusTests",
            dependencies: [
                "Locus", "Nimble",
            ],
            path: "Tests"
        ),
    ]
)
