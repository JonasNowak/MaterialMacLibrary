import Foundation
import Combine
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Observable Material 3 theme object holding the palette and all token sets.
/// Mirrors the role of DMS `ThemeStore` without any dependency on DMS internals.
@MainActor
public final class MaterialTheme: ObservableObject {
    @Published public var palette: MaterialPalette
    @Published public var dank16: MaterialDank16Palette
    @Published public var shapeTokens: MaterialShapeTokens
    @Published public var motionTokens: MaterialMotionTokens
    @Published public var typographyTokens: MaterialTypographyTokens
    @Published public var surfaceTokens: MaterialSurfaceTokens
    @Published public var shadowTokens: MaterialShadowTokens
    @Published public var isLightMode: Bool
    @Published public var activeThemeName: String

    public init(
        palette: MaterialPalette = .defaultDark,
        dank16: MaterialDank16Palette = .default,
        shapeTokens: MaterialShapeTokens = MaterialShapeTokens(),
        motionTokens: MaterialMotionTokens = MaterialMotionTokens(),
        typographyTokens: MaterialTypographyTokens = MaterialTypographyTokens(),
        surfaceTokens: MaterialSurfaceTokens = MaterialSurfaceTokens(),
        shadowTokens: MaterialShadowTokens = MaterialShadowTokens(),
        isLightMode: Bool? = nil,
        activeThemeName: String = "default"
    ) {
        self.palette = palette
        self.dank16 = dank16
        self.shapeTokens = shapeTokens
        self.motionTokens = motionTokens
        self.typographyTokens = typographyTokens
        self.surfaceTokens = surfaceTokens
        self.shadowTokens = shadowTokens
        self.isLightMode = isLightMode ?? !palette.isDark
        self.activeThemeName = activeThemeName
    }

    // MARK: - Cached SwiftUI Colors

    #if canImport(SwiftUI)
    public var primary: Color { palette.primary.swiftUIColor }
    public var onPrimary: Color { palette.onPrimary.swiftUIColor }
    public var primaryContainer: Color { palette.primaryContainer.swiftUIColor }
    public var onPrimaryContainer: Color { palette.onPrimaryContainer.swiftUIColor }
    public var inversePrimary: Color { palette.inversePrimary.swiftUIColor }

    public var secondary: Color { palette.secondary.swiftUIColor }
    public var onSecondary: Color { palette.onSecondary.swiftUIColor }
    public var secondaryContainer: Color { palette.secondaryContainer.swiftUIColor }
    public var onSecondaryContainer: Color { palette.onSecondaryContainer.swiftUIColor }

    public var tertiary: Color { palette.tertiary.swiftUIColor }
    public var onTertiary: Color { palette.onTertiary.swiftUIColor }
    public var tertiaryContainer: Color { palette.tertiaryContainer.swiftUIColor }
    public var onTertiaryContainer: Color { palette.onTertiaryContainer.swiftUIColor }

    public var surface: Color { palette.surface.swiftUIColor }
    public var onSurface: Color { palette.onSurface.swiftUIColor }
    public var surfaceVariant: Color { palette.surfaceVariant.swiftUIColor }
    public var onSurfaceVariant: Color { palette.onSurfaceVariant.swiftUIColor }
    public var surfaceTint: Color { palette.surfaceTint.swiftUIColor }

    public var surfaceContainerLowest: Color { palette.surfaceContainerLowest.swiftUIColor }
    public var surfaceContainerLow: Color { palette.surfaceContainerLow.swiftUIColor }
    public var surfaceContainer: Color { palette.surfaceContainer.swiftUIColor }
    public var surfaceContainerHigh: Color { palette.surfaceContainerHigh.swiftUIColor }
    public var surfaceContainerHighest: Color { palette.surfaceContainerHighest.swiftUIColor }

    public var background: Color { palette.background.swiftUIColor }
    public var onBackground: Color { palette.onBackground.swiftUIColor }
    public var outline: Color { palette.outline.swiftUIColor }
    public var outlineVariant: Color { palette.outlineVariant.swiftUIColor }
    public var scrim: Color { palette.scrim.swiftUIColor }
    public var shadow: Color { palette.shadow.swiftUIColor }

    public var error: Color { palette.error.swiftUIColor }
    public var onError: Color { palette.onError.swiftUIColor }
    public var errorContainer: Color { palette.errorContainer.swiftUIColor }
    public var onErrorContainer: Color { palette.onErrorContainer.swiftUIColor }

    public var warning: Color { palette.warning.swiftUIColor }
    public var onWarning: Color { palette.onWarning.swiftUIColor }
    public var warningContainer: Color { palette.warningContainer.swiftUIColor }
    public var onWarningContainer: Color { palette.onWarningContainer.swiftUIColor }

    public var info: Color { palette.info.swiftUIColor }
    public var onInfo: Color { palette.onInfo.swiftUIColor }
    public var infoContainer: Color { palette.infoContainer.swiftUIColor }
    public var onInfoContainer: Color { palette.onInfoContainer.swiftUIColor }

    public var success: Color { palette.success.swiftUIColor }
    public var onSuccess: Color { palette.onSuccess.swiftUIColor }
    public var successContainer: Color { palette.successContainer.swiftUIColor }
    public var onSuccessContainer: Color { palette.onSuccessContainer.swiftUIColor }

    // MARK: - Adaptive Surface Helpers

    /// Adaptive background for bar widget capsules and floating surfaces.
    /// Larger `cornerRadius` values select the higher (more elevated) container level.
    public func surfaceBackground(
        cornerRadius: CGFloat = 16,
        tintStrength: Double = 0.0,
        opacity: Double? = nil
    ) -> Color {
        let base: MaterialColor
        if isLightMode {
            base = palette.surfaceContainerLowest
        } else {
            base = cornerRadius >= 24 ? palette.surfaceContainerHighest : palette.surfaceContainerHigh
        }
        let op = opacity ?? surfaceTokens.surfaceOpacity
        let tinted = tintStrength > 0 ? mix(base, palette.primary, amount: tintStrength) : base.swiftUIColor
        return tinted.opacity(op)
    }

    /// Adaptive background for cards, tiles, and rows inside panels/popouts.
    public func cardBackground(
        tintStrength: Double = 0.0,
        opacity: Double? = nil
    ) -> Color {
        let isGlass = surfaceTokens.surfaceOpacity < 0.99 || surfaceTokens.popupTransparency < 0.99
        let base: MaterialColor
        if isGlass {
            base = isLightMode ? palette.surfaceContainerLowest : palette.surfaceContainerHigh
        } else {
            base = isLightMode ? palette.surfaceContainerLowest : palette.surfaceContainerHigh
        }
        let baseOpacity: Double = isGlass ? (isLightMode ? 0.75 : 0.68) : 1.0
        let tinted = tintStrength > 0 ? mix(base, palette.primary, amount: tintStrength) : base.swiftUIColor
        return tinted.opacity(opacity ?? baseOpacity)
    }

    /// Subtle progress/gauge track color visible in both Light and Dark mode.
    public var subtleTrackColor: Color {
        isLightMode ? outlineVariant.opacity(0.55) : Color.white.opacity(0.14)
    }

    /// Crisp perimeter border stroke color for floating glass and surface panels.
    public var panelBorderColor: Color {
        isLightMode ? outlineVariant.opacity(0.65) : outlineVariant.opacity(0.38)
    }

    /// Elevation shadow color scaled appropriately for Light Mode vs Dark Mode.
    public func adaptiveShadowColor(baseOpacity: Double = 0.35) -> Color {
        Color.black.opacity(isLightMode ? baseOpacity * 0.45 : baseOpacity)
    }

    // MARK: - Typography & Shape Helpers

    /// Scales a base corner radius through the shape tokens.
    public func cornerRadius(base: CGFloat) -> CGFloat {
        CGFloat(shapeTokens.scaled(Double(base)))
    }

    public func font(size: CGFloat, weight: Font.Weight = .regular, mono: Bool = false, display: Bool = false) -> Font {
        let scaledSize = size * CGFloat(typographyTokens.fontScale)
        let family = mono ? typographyTokens.fontFamilyMono : (display ? typographyTokens.fontFamilyDisplay : typographyTokens.fontFamilyUI)
        let lower = family.lowercased()
        if lower == "system" || lower == "sf pro" || lower.isEmpty {
            return .system(size: scaledSize, weight: weight, design: mono ? .monospaced : .default)
        } else if lower == "sf mono" && mono {
            return .system(size: scaledSize, weight: weight, design: .monospaced)
        } else if lower == "new york" || lower == "serif" {
            return .system(size: scaledSize, weight: weight, design: .serif)
        } else if lower == "sf pro rounded" || lower == "rounded" {
            return .system(size: scaledSize, weight: weight, design: .rounded)
        }
        return .custom(family, size: scaledSize).weight(weight)
    }
    #endif
}

// MARK: - SwiftUI Environment

#if canImport(SwiftUI)
/// Linear sRGB mix of two token colors; `amount` 0 = a, 1 = b.
private func mix(_ a: MaterialColor, _ b: MaterialColor, amount: Double) -> Color {
    let t = min(1.0, max(0.0, amount))
    return MaterialColor(
        red: a.red + (b.red - a.red) * t,
        green: a.green + (b.green - a.green) * t,
        blue: a.blue + (b.blue - a.blue) * t,
        alpha: a.alpha + (b.alpha - a.alpha) * t
    ).swiftUIColor
}

public struct MaterialThemeEnvironmentKey: EnvironmentKey {
    public static var defaultValue: MaterialTheme {
        // SwiftUI materializes environment default values on the main actor.
        MainActor.assumeIsolated { MaterialTheme() }
    }
}

public extension EnvironmentValues {
    var materialTheme: MaterialTheme {
        get { self[MaterialThemeEnvironmentKey.self] }
        set { self[MaterialThemeEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Injects a `MaterialTheme` into the environment as `\.materialTheme`.
    func materialTheme(_ theme: MaterialTheme) -> some View {
        environment(\.materialTheme, theme)
    }
}
#endif
