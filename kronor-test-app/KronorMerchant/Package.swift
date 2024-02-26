// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KronorMerchant",
    defaultLocalization: "en",
    platforms: [
      .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "KronorMerchant",
            targets: ["KronorMerchant"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apollographql/apollo-ios.git",
            .upToNextMinor(from: "1.2.0")
        ),
    ],
    targets: [
        .target(
            name: "KronorMerchant",
            dependencies: [
                .product(name: "ApolloAPI", package: "apollo-ios"),
                .product(name: "ApolloWebSocket", package: "apollo-ios"),
            ],
            path: "./"
        ),
    ]
)
