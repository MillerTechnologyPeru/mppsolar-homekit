// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "mppsolar-homekit",
    platforms: [.macOS(.v10_12)],
    products: [
        .executable(
            name: "mppsolar-homekit",
            targets: ["mppsolar-homekit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/MillerTechnologyPeru/MPPSolar.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/MillerTechnologyPeru/HAP.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            .upToNextMinor(from: "0.0.1")
        )
    ],
    targets: [
        .target(
            name: "mppsolar-homekit",
            dependencies: [
                "MPPSolar",
                "HAP",
                "ArgumentParser"
            ]
        )
    ]
)
