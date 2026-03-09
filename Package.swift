// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ZenAvatar",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ZenAvatar",
            targets: ["ZenAvatar"]
        ),
    ],
    targets: [
        .target(
            name: "ZenAvatar"
        ),
        .testTarget(
            name: "ZenAvatarTests",
            dependencies: ["ZenAvatar"]
        ),
    ]
)
