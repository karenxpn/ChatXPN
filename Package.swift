// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatXPN",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ChatXPN",
            targets: ["ChatXPN"]),
    ], dependencies: [
        .package(url: "https://github.com/SignTranslate/NotraAuth.git", branch: "main"),
        .package(url: "https://github.com/aheze/Popovers.git", .upToNextMajor(from: "1.3.2")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.4.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ChatXPN",
        dependencies: [
            "Popovers",
            "NotraAuth",
            .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
        ]),
        .testTarget(
            name: "ChatXPNTests",
            dependencies: ["ChatXPN"]),
    ]
)
