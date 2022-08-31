// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatastoreLib",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "DatastoreLib",
            targets: ["DatastoreLib"]
        ),
    ],
    dependencies: [
        .package(name: "EasyStash", url: "https://github.com/onmyway133/EasyStash", .exact("1.1.8")),
    ],
    targets: [
        .target(
            name: "DatastoreLib",
            dependencies: ["EasyStash"]
        ),
        .testTarget(
            name: "FrameworkTests",
            dependencies: ["DatastoreLib"]
        ),
    ]
)
