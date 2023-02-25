// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "mppsolar-homekit",
    platforms: [.macOS(.v12)],
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
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.2.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "mppsolar-homekit",
            dependencies: [
                .product(
                    name: "MPPSolar",
                    package: "MPPSolar"
                ),
                .product(
                    name: "HAP",
                    package: "HAP"
                ),
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                )
            ]
        )
    ]
)
