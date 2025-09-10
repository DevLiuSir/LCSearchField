// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LCSearchField",
    platforms: [
        .macOS(.v14)
    ],
    
    products: [
        .library(
            name: "LCSearchField",
            targets: ["LCSearchField"]),
    ],
    targets: [
        .target(
            name: "LCSearchField"),
        .testTarget(
            name: "LCSearchFieldTests",
            dependencies: ["LCSearchField"]),
    ]
)
