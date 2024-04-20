// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "wk-project",
    products: [
          .executable(
              name: "wk-project",
              targets: ["Watch Kit Project Builder"]
          )
      ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.1"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .executableTarget(
            name: "Watch Kit Project Builder",
            dependencies: [
                "ZIPFoundation",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources",
            resources: [
                .copy("Resources"),
            ]
        ),
    ]
)
