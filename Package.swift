// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "hometask1",
    defaultLocalization: "en",
    products: [
        .library(name: "DangerDepsHomeTask", type: .dynamic, targets: ["hometask1"])
    ],
    dependencies: [
        .package(name: "danger-swift", url: "https://github.com/danger/swift.git", from: "1.0.0"),
        .package(name: "DangerSwiftCoverage", url: "https://github.com/f-meloni/danger-swift-coverage", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "hometask1",
            dependencies: ["danger-swift", "DangerSwiftCoverage"],
            path: "MVVM-C", 
            sources: ["MVVM-C.swift"]),
    ]
)
