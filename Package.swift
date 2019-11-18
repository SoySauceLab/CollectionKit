// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CollectionKit",
    products: [
        .library(name: "CollectionKit", targets: ["CollectionKit"])
    ],
    targets: [
        .target(
            name: "CollectionKit",
            path: "Sources"
        )
    ]
)
