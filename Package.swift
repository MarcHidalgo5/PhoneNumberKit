// swift-tools-version: 5.9
import PackageDescription
import Foundation

let skipBuildIsEnabled = ProcessInfo.processInfo.environment["SKIP_ENABLED"] != nil

let packageDependencies: [Package.Dependency] = skipBuildIsEnabled
    ? [
        .package(url: "https://source.skip.tools/skip.git", from: "1.8.0"),
        .package(url: "https://source.skip.tools/skip-android-bridge.git", "0.0.0"..<"2.0.0")
    ]
    : []

let targetDependencies: [Target.Dependency] = skipBuildIsEnabled
    ? [
        .product(name: "SkipAndroidBridge", package: "skip-android-bridge")
    ]
    : []

let targetPlugins: [Target.PluginUsage] = skipBuildIsEnabled
    ? [.plugin(name: "skipstone", package: "skip")]
    : []

let targetExcludes: [String] = [
    "Resources/Original",
    "Resources/README.md",
    "Resources/update_metadata.sh",
    "Info.plist"
] + (skipBuildIsEnabled ? ["UI"] : [])

let package = Package(
    name: "PhoneNumberKit",
    platforms: [
        .iOS(skipBuildIsEnabled ? .v16 : .v12), .macOS(.v10_13), .tvOS(.v12), .watchOS(.v4)
    ],
    products: [
        .library(name: "PhoneNumberKit", targets: ["PhoneNumberKit"]),
        .library(name: "PhoneNumberKit-Static", type: .static, targets: ["PhoneNumberKit"]),
        .library(name: "PhoneNumberKit-Dynamic", type: .dynamic, targets: ["PhoneNumberKit"])
    ],
    dependencies: packageDependencies,
    targets: [
        .target(name: "PhoneNumberKit",
                dependencies: targetDependencies,
                exclude: targetExcludes,
                resources: [
                    .copy("Resources")
                ],
                plugins: targetPlugins),
        .testTarget(name: "PhoneNumberKitTests",
                    dependencies: ["PhoneNumberKit"],
                    path: "PhoneNumberKitTests",
                    exclude: ["Info.plist"])
    ]
)
