// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swiftMVPInfra",
    platforms: [
        .macOS(.v12),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "swiftMVPInfra",
            targets: ["swiftMVPInfra"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "swiftMVPInfra",
            dependencies: []
        ),
        .testTarget(
            name: "swiftMVPInfraTests",
            dependencies: ["swiftMVPInfra"]
        )
    ]
)
