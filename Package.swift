// swift-tools-version:5.9
import PackageDescription
let package = Package(
    name: "FreshdeskSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FreshdeskSDK",
            targets: ["FreshdeskSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "FreshdeskSDK",
            path: "FreshdeskSDK.xcframework"
        ),
    ]
)
