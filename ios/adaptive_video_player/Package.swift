// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "adaptive_video_player",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        // Library names cannot contain underscores.
        .library(name: "adaptive-video-player", targets: ["adaptive_video_player"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "adaptive_video_player",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
