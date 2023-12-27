// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "RemoveBg",
    platforms: [
        .macOS(.v12), .iOS(.v16)
    ],
    products: [
        .library(
            name: "RemoveBg",
            targets: ["RemoveBg"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.0.0")
    ],
    targets: [
        .target(name: "RemoveBg"),
        .testTarget(
            name: "RemoveBgTests",
            dependencies: [
                "RemoveBg",
                .product(name: "MultipartKit", package: "multipart-kit")
                ]
            ),
    ]
)
