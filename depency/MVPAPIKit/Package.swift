// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MVPAPIKit",
    platforms: [.iOS(.v16), .macOS(.v12)],    
    products: [
        .library(
            name: "MVPAPIKit",
            targets: ["MVPAPIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.13.5"),
        .package(url: "https://github.com/alfianlosari/GPTEncoder.git", exact: "1.0.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MVPAPIKit",
            dependencies: [
                .product(name: "Moya", package: "Moya"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "GPTEncoder", package: "GPTEncoder")
            ]),
        .testTarget(
            name: "MVPAPIKitTests",
            dependencies: ["MVPAPIKit"]),
    ]
)
