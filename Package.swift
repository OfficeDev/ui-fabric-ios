// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OfficeUIFabric",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "OfficeUIFabric",
            targets: ["OfficeUIFabric"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OfficeUIFabric",
            dependencies: [],
            path: "OfficeUIFabric"),
        .testTarget(
            name: "OfficeUIFabricTests",
            dependencies: ["OfficeUIFabric"],
            path: "OfficeUIFabric.Tests"),
    ]
)
