// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AbTesting-iOS",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "AbTesting",
            targets: ["AbTesting"]
        ),
        .library(
            name: "AbTestingFirebase",
            targets: ["AbTestingFirebase"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            "10.0.0"..<"12.0.0"
        )
    ],
    targets: [
        .target(
            name: "AbTesting",
            dependencies: [],
            path: "Sources/AbTesting"
        ),
        .target(
            name: "AbTestingFirebase",
            dependencies: [
                "AbTesting",
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
            ],
            path: "Sources/AbTestingFirebase"
        ),
        .testTarget(
            name: "AbTestingTests",
            dependencies: ["AbTesting"],
            path: "Tests/AbTestingTests"
        )
    ]
)
