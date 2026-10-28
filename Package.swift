// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "KPD",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "KPD", targets: ["KPD"]),
        .executable(name: "KPDCoreSmokeTests", targets: ["KPDCoreSmokeTests"]),
        .library(name: "KPDCore", targets: ["KPDCore"])
    ],
    targets: [
        .executableTarget(
            name: "KPD",
            dependencies: ["KPDCore"],
            path: "Sources/KPD",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "KPDCore",
            path: "Sources/KPDCore"
        ),
        .executableTarget(
            name: "KPDCoreSmokeTests",
            dependencies: ["KPDCore"],
            path: "Tests/KPDCoreSmokeTests"
        )
    ]
)
