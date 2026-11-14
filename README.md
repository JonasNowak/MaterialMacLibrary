# MaterialMacLibrary

Pure SwiftUI and CoreGraphics Material Design 3 component, shape, and token library for macOS 14+, extracted from [DankMacShell](https://github.com/JonasNowak/DankMacShell) with zero dependency on DMS internals or Rust FFI.

## Requirements

- macOS 14.0+
- Swift 6.0 toolchain (`swiftLanguageModes: [.v5]`)

## Installation (Swift Package Manager)

Add `MaterialMacLibrary` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/JonasNowak/MaterialMacLibrary.git", from: "0.1.0")
]
```

And depend on the umbrella product or individual modules:

```swift
.product(name: "MaterialMacLibrary", package: "MaterialMacLibrary")
// or granularly: "MaterialTokens", "MaterialShapes", "MaterialComponents"
```

## Modules

- **`MaterialTokens`**: `MaterialColor`, `MaterialPalette`, `MaterialTheme` (`@Environment(\.materialTheme)`), `MaterialShapeTokens`, `MaterialBezierCurve`, `MaterialMotionTokens`, `MaterialTypographyTokens`, `MaterialSurfaceTokens`, `MaterialShadowTokens`, `MaterialDank16Palette`, `MaterialMatugenScheme`, `MaterialCornerStyle`.
- **`MaterialShapes`**: `GothEarCornerShape`, `InvertedCutoutCornerShape`, `SegmentedPillShape`, `SlantedParallelogramShape`, `GeometricAvatarShape`, `AvatarShapeGenerator`, `WavyVisualizerRing`.
- **`MaterialComponents`**: `VisualEffectBlur`, `GlassSurfaceBackground`, `MaterialSettingsCard`, `MaterialSegmentedControl`, `MaterialSliderRow`, `MaterialToggleRow`, `MaterialHeaderActionButton`, `MaterialPillSlider`, `MaterialTile`, `MaterialDetailPage`, `MaterialQuickTileItem`, `MaterialQuickTileButton`, `MaterialQuickTilesGrid`, `MaterialEditChromeStyle`, `MaterialFloatingEditChrome`, `HoverBounceModifier`, `SegmentedPillModifier`, `SquigglyProgressBar`, `MaterialToastCard`, `MaterialOSDPill`, `MaterialActionTile`, `MaterialPopoutSurfaceContainer`, `PopoutLayoutHelper`, `PopoutAnimationHelper`.

## Usage

```swift
import SwiftUI
import MaterialMacLibrary

struct SettingsView: View {
    @StateObject private var theme = MaterialTheme(
        palette: .defaultDark,
        activeThemeName: "Purple"
    )
    @State private var enabled = true

    var body: some View {
        MaterialSettingsCard(title: "Appearance") {
            MaterialToggleRow(title: "Frosted Glass", isOn: $enabled)
        }
        .materialTheme(theme)
    }
}
```

## Testing

```sh
./scripts/test.sh
```

Runs the Swift Testing suite (`64` tests across `12` suites), supporting both full Xcode and Apple CommandLineTools toolchains.

## License

MIT License — see [LICENSE](LICENSE).
