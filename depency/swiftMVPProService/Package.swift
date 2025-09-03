// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swiftMVPProService",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "swiftMVPProService",
            targets: ["swiftMVPProService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "swiftMVPProService",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios")
            ]),
        .testTarget(
            name: "swiftMVPProServiceTests",
            dependencies: ["swiftMVPProService"]),
    ]
)