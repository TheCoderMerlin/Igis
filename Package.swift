// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Igis",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
          name: "Igis",
          type: .dynamic,
          targets: ["Igis"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.42.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Igis",
            dependencies: ["NIO",
                           "NIOHTTP1",
                           "NIOWebSocket"]),
        .testTarget(
          name: "IgisTests",
          dependencies: ["Igis"]),
    ]
)
