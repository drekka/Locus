// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Locus",
    platforms: [
        .iOS(.v15),
        .tvOS(.v11),
        //.macOS(.v10_11),
    ],
    products: [
        .library(
            name: "Locus",
            targets: ["Locus"]
        ),
    ],
    dependencies: [
        .package(name: "Nimble", url: "https://github.com/quick/nimble", branch: "main"),
        .package(name: "UsefulThings", url: "https://github.com/drekka/UsefulThings", branch: "main"),
    ],
    targets: [
        .target(
            name: "Locus",
            dependencies: [
                "UsefulThings"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "LocusTests",
            dependencies: [
                "Locus", "Nimble",
            ],
            path: "Tests",
            resources: [
                .copy("Test files/Settings.bundle"),
                .copy("Test files/Missing child pane.bundle"),
                .copy("Test files/Incorrect setting type.bundle"),
                .copy("Test files/Bad plist.bundle"),
                .copy("Test files/Bad plist content.bundle"),
                .copy("Test files/Settings.json"),
                .copy("Test files/Invalid.json"),
            ]
        ),
    ]
)
