// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TasteIndia",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TasteIndia",
            targets: ["TasteIndia"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TasteIndia",
            dependencies: [],
            path: "TasteIndia"
        ),
        .testTarget(
            name: "TasteIndiaTests",
            dependencies: ["TasteIndia"],
            path: "TasteIndiaTests",
            resources: [
                .process("Fixtures")
            ]
        ),
    ]
)