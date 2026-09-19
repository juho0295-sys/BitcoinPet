// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "BitcoinPet",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "BitcoinPet", targets: ["BitcoinPet"])],
    targets: [
        .executableTarget(
            name: "BitcoinPet",
            resources: [.process("Resources")]
        )
    ]
)
