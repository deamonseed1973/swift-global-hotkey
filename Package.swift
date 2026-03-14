// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swift-global-hotkey",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "GlobalHotKey", targets: ["GlobalHotKey"]),
    ],
    targets: [
        .target(
            name: "GlobalHotKey",
            path: "Sources/GlobalHotKey",
            linkerSettings: [
                .linkedFramework("Carbon"),
                .linkedFramework("AppKit"),
            ]
        ),
        .testTarget(
            name: "GlobalHotKeyTests",
            dependencies: ["GlobalHotKey"],
            path: "Tests/GlobalHotKeyTests"
        ),
    ]
)
