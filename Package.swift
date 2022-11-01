// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "CollectionKit",
    platforms: [
       .iOS(.v9),
    ],
    products: [
        .library(
            name: "CollectionKit", 
            targets: ["CollectionKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CollectionKit", 
            dependencies: [],
            path: "Sources"),
    ]
)
