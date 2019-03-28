// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Cairo",
    products: [
        .library(name: "CCairoJPEG", targets: ["CCairoJPEG"]),
        .library(name: "Cairo", targets: ["Cairo"])
    ],
    dependencies: [
    ],
    targets: [
        .systemLibrary(
            name: "CCairo",
            pkgConfig: "cairo",
            providers: [
                .apt(["libcairo-dev"]),
                .brew(["cairo"]),
            ]
        ),
        .systemLibrary(
            name: "CFontConfig",
            pkgConfig: "fontconfig",
            providers: [
                .brew(["fontconfig"]),
                .apt(["libfontconfig-dev"])
            ]
        ),
        .systemLibrary(
            name: "CFreeType",
            pkgConfig: "freetype2",
            providers: [
                .apt(["libfreetype6-dev"]),
                .brew(["freetype2"])
            ]
        ),
        .systemLibrary(
            name: "Cjpeg",
            pkgConfig: "libjpeg",
            providers: [
                .brew(["libjpeg"]),
                .apt(["libjpeg-dev"])
            ]
        ),
        .target(
            name: "CCairoJPEG",
            dependencies: [
                "CCairo",
                "Cjpeg"
            ],
            path: "Sources/CCairoJPEG"
        ),
        .target(
            name: "Cairo",
            dependencies: [
                "CCairo",
                "CCairoJPEG",
                "CFontConfig",
                "CFreeType",
            ]
        )
    ]
)
