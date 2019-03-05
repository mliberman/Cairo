// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Cairo",
    products: [
        .library(name: "Cairo", targets: ["Cairo"])
    ],
    dependencies: [
        .package(url: "https://github.com/mliberman/CCairo.git", from: "1.2.0"),
        .package(url: "https://github.com/mliberman/CFontConfig.git", from: "1.1.0"),
        .package(url: "https://github.com/mliberman/CFreeType.git", from: "1.1.0"),
    ],
    targets: [
        .target(name: "Cairo", dependencies: ["CCairo", "CFontConfig", "CFreeType"])
    ]
)
