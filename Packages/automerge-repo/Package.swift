// swift-tools-version: 5.9

import Foundation
import PackageDescription

var globalSwiftSettings: [PackageDescription.SwiftSetting] = []

if ProcessInfo.processInfo.environment["LOCAL_BUILD"] != nil {
    globalSwiftSettings.append(.enableExperimentalFeature("StrictConcurrency"))
}

let package = Package(
    name: "automerge-repo",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "AutomergeRepo",
            targets: ["AutomergeRepo"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/automerge/automerge-swift",
            .upToNextMajor(from: "0.5.7")
        ),
        .package(url: "https://github.com/outfoxx/PotentCodables", .upToNextMajor(from: "3.1.0")),
        .package(url: "https://github.com/keefertaylor/Base58Swift", .upToNextMajor(from: "2.1.14")),
    ],
    targets: [
        .target(
            name: "AutomergeRepo",
            dependencies: ["automerge-swift"]
        ),
        .testTarget(
            name: "AutomergeRepoTests",
            dependencies: ["AutomergeRepo"]
        ),
    ]
)
