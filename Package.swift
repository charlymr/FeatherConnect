// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IRLServerConnection",
    platforms: [
       .macOS(.v10_15),
       .iOS(.v11),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "IRLServerConnection",
            targets: ["IRLServerConnection"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/Alamofire/Alamofire", from: "5.4.3"),
         .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "IRLServerConnection",
            dependencies: [
                /// drivers
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON")
            ]),
        .testTarget(
            name: "IRLServerConnectionTests",
            dependencies: ["IRLServerConnection"]),
    ]
)
