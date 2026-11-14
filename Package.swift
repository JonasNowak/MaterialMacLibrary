// swift-tools-version: 6.0
import PackageDescription

// MaterialMacLibrary: standalone Material Design 3 token, shape, and component library
// for macOS, extracted from DankMacShell (DMS). Zero external dependencies.
let package = Package(
    name: "MaterialMacLibrary",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MaterialMacLibrary", targets: ["MaterialMacLibrary"]),
        .library(name: "MaterialTokens", targets: ["MaterialTokens"]),
        .library(name: "MaterialShapes", targets: ["MaterialShapes"]),
        .library(name: "MaterialComponents", targets: ["MaterialComponents"]),
    ],
    targets: [
        // Pure tokens: color, palette, shape/motion/typography/surface/shadow tokens, theme object.
        .target(name: "MaterialTokens"),
        // CoreGraphics/SwiftUI Shape implementations built on the token types.
        .target(name: "MaterialShapes", dependencies: ["MaterialTokens"]),
        // AppKit/SwiftUI views, glass surfaces, cards, sliders, tiles, popouts.
        .target(name: "MaterialComponents", dependencies: ["MaterialTokens", "MaterialShapes"]),
        // Umbrella target re-exporting the whole library.
        .target(
            name: "MaterialMacLibrary",
            dependencies: ["MaterialTokens", "MaterialShapes", "MaterialComponents"]
        ),
        .testTarget(name: "MaterialMacLibraryTests", dependencies: ["MaterialMacLibrary"]),
    ],
    swiftLanguageModes: [.v5]
)
