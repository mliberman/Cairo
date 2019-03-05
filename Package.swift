// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Cairo",
    products: [
        .library(name: "Cairo", targets: ["Cairo"])
    ],
    dependencies: [
        .package(url: "https://github.com/PureSwift/CCairo.git", from: "1.1.1"),
        .package(url: "https://github.com/PureSwift/CFontConfig.git", from: "1.0.1"),
        .package(url: "https://github.com/PureSwift/CFreeType.git", from: "1.0.4")
    ],
    targets: [
        .target(name: "Cairo")
    ]
)
