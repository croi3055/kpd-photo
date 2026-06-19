// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WASDPhoto",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "WASDPhoto", targets: ["WASDPhoto"]),
        .executable(name: "WASDPhotoCoreSmokeTests", targets: ["WASDPhotoCoreSmokeTests"]),
        .library(name: "WASDPhotoCore", targets: ["WASDPhotoCore"])
    ],
    targets: [
        .executableTarget(
            name: "WASDPhoto",
            dependencies: ["WASDPhotoCore"],
            path: "Sources/WASDPhoto",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "WASDPhotoCore",
            path: "Sources/WASDPhotoCore"
        ),
        .executableTarget(
            name: "WASDPhotoCoreSmokeTests",
            dependencies: ["WASDPhotoCore"],
            path: "Tests/WASDPhotoCoreSmokeTests"
        )
    ]
)
