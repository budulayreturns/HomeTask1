// swift-tools-version:5.3

import Foundation
import PackageDescription

let package = Package(
    name: "MVVM-C",
    defaultLocalization: "ru",
    platforms: [
        .iOS(.v14)
    ],
    products: [
            .library(name: "MVVM-C", type: .dynamic, targets: ["MVVM-C"]),
        ],
        dependencies: [
            .package(name: "danger-swift", url: "https://github.com/danger/swift.git", from: "3.0.0"),

        ],
        targets: [
            .target(
                name: "MVVM-C",
                dependencies: [
                    .product(name: "Danger", package: "danger-swift"),
                    
                ],
                path: "./MVVM-C",
                exclude: ["Info.plist"]
            ),
            .testTarget(
                name: "MVVM-CTests",
                dependencies: ["MVVM-C"],
                path: "./MVVM-CTests",
                exclude: ["Info.plist"]
            ),
        ]
)
