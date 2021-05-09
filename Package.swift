// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatherConnect",
    platforms: [
       .macOS(.v10_15),
       .iOS(.v11),
    ],
    products: [
        .library(
            name: "FeatherConnect",
            targets: ["FeatherConnect"]),
        .library(
            name: "FeatherBlogModule",
            targets: ["FeatherBlogModule"]),
    ],
    dependencies: [
         .package(url: "https://github.com/Alamofire/Alamofire", from: "5.4.3"),
         .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "FeatherConnect",
            dependencies: [
                /// drivers
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON")
            ]),

        .target(
            name: "FeatherBlogModule",
            dependencies: [
                /// Mapper
                .target(name: "FeatherConnect"),
            ]),
        .testTarget(
            name: "FeatherBlogModuleTests",
            dependencies: [ "FeatherBlogModule" ]),
    ]
)
