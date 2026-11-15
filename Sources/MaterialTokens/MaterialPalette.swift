import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Material Design 3 full color token set — exact role parity with DMS `ThemePalette`.
public struct MaterialPalette: Sendable, Codable, Equatable {
    public var name: String
    public var isDark: Bool

    // Primary
    public var primary: MaterialColor
    public var onPrimary: MaterialColor
    public var primaryContainer: MaterialColor
    public var onPrimaryContainer: MaterialColor
    public var inversePrimary: MaterialColor

    // Secondary
    public var secondary: MaterialColor
    public var onSecondary: MaterialColor
    public var secondaryContainer: MaterialColor
    public var onSecondaryContainer: MaterialColor

    // Tertiary
    public var tertiary: MaterialColor
    public var onTertiary: MaterialColor
    public var tertiaryContainer: MaterialColor
    public var onTertiaryContainer: MaterialColor

    // Surface & Background
    public var surface: MaterialColor
    public var onSurface: MaterialColor
    public var surfaceVariant: MaterialColor
    public var onSurfaceVariant: MaterialColor
    public var surfaceTint: MaterialColor

    public var surfaceContainerLowest: MaterialColor
    public var surfaceContainerLow: MaterialColor
    public var surfaceContainer: MaterialColor
    public var surfaceContainerHigh: MaterialColor
    public var surfaceContainerHighest: MaterialColor

    public var background: MaterialColor
    public var onBackground: MaterialColor

    // Outline
    public var outline: MaterialColor
    public var outlineVariant: MaterialColor

    // Error & Status
    public var error: MaterialColor
    public var onError: MaterialColor
    public var errorContainer: MaterialColor
    public var onErrorContainer: MaterialColor

    public var warning: MaterialColor
    public var onWarning: MaterialColor
    public var warningContainer: MaterialColor
    public var onWarningContainer: MaterialColor

    public var info: MaterialColor
    public var onInfo: MaterialColor
    public var infoContainer: MaterialColor
    public var onInfoContainer: MaterialColor

    public var success: MaterialColor
    public var onSuccess: MaterialColor
    public var successContainer: MaterialColor
    public var onSuccessContainer: MaterialColor

    public var scrim: MaterialColor
    public var shadow: MaterialColor

    public init(
        name: String,
        isDark: Bool,
        primary: MaterialColor,
        onPrimary: MaterialColor,
        primaryContainer: MaterialColor,
        onPrimaryContainer: MaterialColor,
        inversePrimary: MaterialColor,
        secondary: MaterialColor,
        onSecondary: MaterialColor,
        secondaryContainer: MaterialColor,
        onSecondaryContainer: MaterialColor,
        tertiary: MaterialColor,
        onTertiary: MaterialColor,
        tertiaryContainer: MaterialColor,
        onTertiaryContainer: MaterialColor,
        surface: MaterialColor,
        onSurface: MaterialColor,
        surfaceVariant: MaterialColor,
        onSurfaceVariant: MaterialColor,
        surfaceTint: MaterialColor,
        surfaceContainerLowest: MaterialColor,
        surfaceContainerLow: MaterialColor,
        surfaceContainer: MaterialColor,
        surfaceContainerHigh: MaterialColor,
        surfaceContainerHighest: MaterialColor,
        background: MaterialColor,
        onBackground: MaterialColor,
        outline: MaterialColor,
        outlineVariant: MaterialColor,
        error: MaterialColor = MaterialColor("#F2B8B5"),
        onError: MaterialColor = MaterialColor("#601410"),
        errorContainer: MaterialColor = MaterialColor("#8C1D18"),
        onErrorContainer: MaterialColor = MaterialColor("#F9DEDC"),
        warning: MaterialColor = MaterialColor("#FFB74D"),
        onWarning: MaterialColor? = nil,
        warningContainer: MaterialColor? = nil,
        onWarningContainer: MaterialColor? = nil,
        info: MaterialColor = MaterialColor("#4FC3F7"),
        onInfo: MaterialColor? = nil,
        infoContainer: MaterialColor? = nil,
        onInfoContainer: MaterialColor? = nil,
        success: MaterialColor = MaterialColor("#81C784"),
        onSuccess: MaterialColor? = nil,
        successContainer: MaterialColor? = nil,
        onSuccessContainer: MaterialColor? = nil,
        scrim: MaterialColor = MaterialColor("#000000"),
        shadow: MaterialColor = MaterialColor("#000000")
    ) {
        self.name = name
        self.isDark = isDark
        self.primary = primary
        self.onPrimary = onPrimary
        self.primaryContainer = primaryContainer
        self.onPrimaryContainer = onPrimaryContainer
        self.inversePrimary = inversePrimary
        self.secondary = secondary
        self.onSecondary = onSecondary
        self.secondaryContainer = secondaryContainer
        self.onSecondaryContainer = onSecondaryContainer
        self.tertiary = tertiary
        self.onTertiary = onTertiary
        self.tertiaryContainer = tertiaryContainer
        self.onTertiaryContainer = onTertiaryContainer
        self.surface = surface
        self.onSurface = onSurface
        self.surfaceVariant = surfaceVariant
        self.onSurfaceVariant = onSurfaceVariant
        self.surfaceTint = surfaceTint
        self.surfaceContainerLowest = surfaceContainerLowest
        self.surfaceContainerLow = surfaceContainerLow
        self.surfaceContainer = surfaceContainer
        self.surfaceContainerHigh = surfaceContainerHigh
        self.surfaceContainerHighest = surfaceContainerHighest
        self.background = background
        self.onBackground = onBackground
        self.outline = outline
        self.outlineVariant = outlineVariant
        self.error = error
        self.onError = onError
        self.errorContainer = errorContainer
        self.onErrorContainer = onErrorContainer
        self.warning = warning
        self.onWarning = onWarning ?? (isDark ? MaterialColor("#462B00") : MaterialColor("#FFFFFF"))
        self.warningContainer = warningContainer ?? (isDark ? MaterialColor("#643F00") : MaterialColor("#FFDEAD"))
        self.onWarningContainer = onWarningContainer ?? (isDark ? MaterialColor("#FFDEAD") : MaterialColor("#281800"))
        self.info = info
        self.onInfo = onInfo ?? (isDark ? MaterialColor("#003548") : MaterialColor("#FFFFFF"))
        self.infoContainer = infoContainer ?? (isDark ? MaterialColor("#004D67") : MaterialColor("#BFE9FF"))
        self.onInfoContainer = onInfoContainer ?? (isDark ? MaterialColor("#BFE9FF") : MaterialColor("#001F2B"))
        self.success = success
        self.onSuccess = onSuccess ?? (isDark ? MaterialColor("#0A3912") : MaterialColor("#FFFFFF"))
        self.successContainer = successContainer ?? (isDark ? MaterialColor("#215126") : MaterialColor("#B8F397"))
        self.onSuccessContainer = onSuccessContainer ?? (isDark ? MaterialColor("#B8F397") : MaterialColor("#022106"))
        self.scrim = scrim
        self.shadow = shadow
    }

    // MARK: - Codable (partial theme JSONs get status-color defaults)

    private enum CodingKeys: String, CodingKey {
        case name, isDark
        case primary, onPrimary, primaryContainer, onPrimaryContainer, inversePrimary
        case secondary, onSecondary, secondaryContainer, onSecondaryContainer
        case tertiary, onTertiary, tertiaryContainer, onTertiaryContainer
        case surface, onSurface, surfaceVariant, onSurfaceVariant, surfaceTint
        case surfaceContainerLowest, surfaceContainerLow, surfaceContainer
        case surfaceContainerHigh, surfaceContainerHighest
        case background, onBackground
        case outline, outlineVariant
        case error, onError, errorContainer, onErrorContainer
        case warning, onWarning, warningContainer, onWarningContainer
        case info, onInfo, infoContainer, onInfoContainer
        case success, onSuccess, successContainer, onSuccessContainer
        case scrim, shadow
    }

    /// Decodes a palette from theme JSON. Core roles are required; omitted status keys
    /// (`error`/`warning`/`info`/`success` families, `scrim`, `shadow`) fall back to the
    /// same defaults as the memberwise initializer (status "on/container" colors derive
    /// from `isDark`), matching DMS partial-theme decoding behavior.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        func opt(_ key: CodingKeys) -> MaterialColor? {
            try? c.decodeIfPresent(MaterialColor.self, forKey: key)
        }
        self.init(
            name: try c.decode(String.self, forKey: .name),
            isDark: try c.decode(Bool.self, forKey: .isDark),
            primary: try c.decode(MaterialColor.self, forKey: .primary),
            onPrimary: try c.decode(MaterialColor.self, forKey: .onPrimary),
            primaryContainer: try c.decode(MaterialColor.self, forKey: .primaryContainer),
            onPrimaryContainer: try c.decode(MaterialColor.self, forKey: .onPrimaryContainer),
            inversePrimary: try c.decode(MaterialColor.self, forKey: .inversePrimary),
            secondary: try c.decode(MaterialColor.self, forKey: .secondary),
            onSecondary: try c.decode(MaterialColor.self, forKey: .onSecondary),
            secondaryContainer: try c.decode(MaterialColor.self, forKey: .secondaryContainer),
            onSecondaryContainer: try c.decode(MaterialColor.self, forKey: .onSecondaryContainer),
            tertiary: try c.decode(MaterialColor.self, forKey: .tertiary),
            onTertiary: try c.decode(MaterialColor.self, forKey: .onTertiary),
            tertiaryContainer: try c.decode(MaterialColor.self, forKey: .tertiaryContainer),
            onTertiaryContainer: try c.decode(MaterialColor.self, forKey: .onTertiaryContainer),
            surface: try c.decode(MaterialColor.self, forKey: .surface),
            onSurface: try c.decode(MaterialColor.self, forKey: .onSurface),
            surfaceVariant: try c.decode(MaterialColor.self, forKey: .surfaceVariant),
            onSurfaceVariant: try c.decode(MaterialColor.self, forKey: .onSurfaceVariant),
            surfaceTint: try c.decode(MaterialColor.self, forKey: .surfaceTint),
            surfaceContainerLowest: try c.decode(MaterialColor.self, forKey: .surfaceContainerLowest),
            surfaceContainerLow: try c.decode(MaterialColor.self, forKey: .surfaceContainerLow),
            surfaceContainer: try c.decode(MaterialColor.self, forKey: .surfaceContainer),
            surfaceContainerHigh: try c.decode(MaterialColor.self, forKey: .surfaceContainerHigh),
            surfaceContainerHighest: try c.decode(MaterialColor.self, forKey: .surfaceContainerHighest),
            background: try c.decode(MaterialColor.self, forKey: .background),
            onBackground: try c.decode(MaterialColor.self, forKey: .onBackground),
            outline: try c.decode(MaterialColor.self, forKey: .outline),
            outlineVariant: try c.decode(MaterialColor.self, forKey: .outlineVariant),
            error: opt(.error) ?? MaterialColor("#F2B8B5"),
            onError: opt(.onError) ?? MaterialColor("#601410"),
            errorContainer: opt(.errorContainer) ?? MaterialColor("#8C1D18"),
            onErrorContainer: opt(.onErrorContainer) ?? MaterialColor("#F9DEDC"),
            warning: opt(.warning) ?? MaterialColor("#FFB74D"),
            onWarning: opt(.onWarning),
            warningContainer: opt(.warningContainer),
            onWarningContainer: opt(.onWarningContainer),
            info: opt(.info) ?? MaterialColor("#4FC3F7"),
            onInfo: opt(.onInfo),
            infoContainer: opt(.infoContainer),
            onInfoContainer: opt(.onInfoContainer),
            success: opt(.success) ?? MaterialColor("#81C784"),
            onSuccess: opt(.onSuccess),
            successContainer: opt(.successContainer),
            onSuccessContainer: opt(.onSuccessContainer),
            scrim: opt(.scrim) ?? MaterialColor("#000000"),
            shadow: opt(.shadow) ?? MaterialColor("#000000")
        )
    }
}

// MARK: - SwiftUI Color convenience accessors
#if canImport(SwiftUI)
public extension MaterialPalette {
    var primaryColor: Color { primary.swiftUIColor }
    var onPrimaryColor: Color { onPrimary.swiftUIColor }
    var primaryContainerColor: Color { primaryContainer.swiftUIColor }
    var onPrimaryContainerColor: Color { onPrimaryContainer.swiftUIColor }
    var inversePrimaryColor: Color { inversePrimary.swiftUIColor }

    var secondaryColor: Color { secondary.swiftUIColor }
    var onSecondaryColor: Color { onSecondary.swiftUIColor }
    var secondaryContainerColor: Color { secondaryContainer.swiftUIColor }
    var onSecondaryContainerColor: Color { onSecondaryContainer.swiftUIColor }

    var tertiaryColor: Color { tertiary.swiftUIColor }
    var onTertiaryColor: Color { onTertiary.swiftUIColor }
    var tertiaryContainerColor: Color { tertiaryContainer.swiftUIColor }
    var onTertiaryContainerColor: Color { onTertiaryContainer.swiftUIColor }

    var surfaceColor: Color { surface.swiftUIColor }
    var onSurfaceColor: Color { onSurface.swiftUIColor }
    var surfaceVariantColor: Color { surfaceVariant.swiftUIColor }
    var onSurfaceVariantColor: Color { onSurfaceVariant.swiftUIColor }
    var surfaceTintColor: Color { surfaceTint.swiftUIColor }

    var surfaceContainerLowestColor: Color { surfaceContainerLowest.swiftUIColor }
    var surfaceContainerLowColor: Color { surfaceContainerLow.swiftUIColor }
    var surfaceContainerColor: Color { surfaceContainer.swiftUIColor }
    var surfaceContainerHighColor: Color { surfaceContainerHigh.swiftUIColor }
    var surfaceContainerHighestColor: Color { surfaceContainerHighest.swiftUIColor }

    var backgroundColor: Color { background.swiftUIColor }
    var onBackgroundColor: Color { onBackground.swiftUIColor }

    var outlineColor: Color { outline.swiftUIColor }
    var outlineVariantColor: Color { outlineVariant.swiftUIColor }

    var errorColor: Color { error.swiftUIColor }
    var onErrorColor: Color { onError.swiftUIColor }
    var errorContainerColor: Color { errorContainer.swiftUIColor }
    var onErrorContainerColor: Color { onErrorContainer.swiftUIColor }

    var warningColor: Color { warning.swiftUIColor }
    var onWarningColor: Color { onWarning.swiftUIColor }
    var warningContainerColor: Color { warningContainer.swiftUIColor }
    var onWarningContainerColor: Color { onWarningContainer.swiftUIColor }

    var infoColor: Color { info.swiftUIColor }
    var onInfoColor: Color { onInfo.swiftUIColor }
    var infoContainerColor: Color { infoContainer.swiftUIColor }
    var onInfoContainerColor: Color { onInfoContainer.swiftUIColor }

    var successColor: Color { success.swiftUIColor }
    var onSuccessColor: Color { onSuccess.swiftUIColor }
    var successContainerColor: Color { successContainer.swiftUIColor }
    var onSuccessContainerColor: Color { onSuccessContainer.swiftUIColor }

    var scrimColor: Color { scrim.swiftUIColor }
    var shadowColor: Color { shadow.swiftUIColor }

    var surfaceDimColor: Color { surfaceDim.swiftUIColor }
    var surfaceBrightColor: Color { surfaceBright.swiftUIColor }
    var inverseSurfaceColor: Color { inverseSurface.swiftUIColor }
    var inverseOnSurfaceColor: Color { inverseOnSurface.swiftUIColor }

    var primaryFixedColor: Color { primaryFixed.swiftUIColor }
    var primaryFixedDimColor: Color { primaryFixedDim.swiftUIColor }
    var onPrimaryFixedColor: Color { onPrimaryFixed.swiftUIColor }
    var onPrimaryFixedVariantColor: Color { onPrimaryFixedVariant.swiftUIColor }

    var secondaryFixedColor: Color { secondaryFixed.swiftUIColor }
    var secondaryFixedDimColor: Color { secondaryFixedDim.swiftUIColor }
    var onSecondaryFixedColor: Color { onSecondaryFixed.swiftUIColor }
    var onSecondaryFixedVariantColor: Color { onSecondaryFixedVariant.swiftUIColor }

    var tertiaryFixedColor: Color { tertiaryFixed.swiftUIColor }
    var tertiaryFixedDimColor: Color { tertiaryFixedDim.swiftUIColor }
    var onTertiaryFixedColor: Color { onTertiaryFixed.swiftUIColor }
    var onTertiaryFixedVariantColor: Color { onTertiaryFixedVariant.swiftUIColor }
}
#endif

// MARK: - M3 Expressive Extended Surface & Fixed Accent Roles

public extension MaterialPalette {
    private func blend(_ a: MaterialColor, _ b: MaterialColor, t: Double) -> MaterialColor {
        let clamped = min(1.0, max(0.0, t))
        return MaterialColor(
            red: a.red + (b.red - a.red) * clamped,
            green: a.green + (b.green - a.green) * clamped,
            blue: a.blue + (b.blue - a.blue) * clamped,
            alpha: a.alpha + (b.alpha - a.alpha) * clamped
        )
    }

    /// M3 Expressive dimmed surface role (N6 dark / N87 light).
    var surfaceDim: MaterialColor {
        isDark ? surface : blend(surfaceContainerHigh, surfaceContainerHighest, t: 0.65)
    }

    /// M3 Expressive bright surface role (N24 dark / N98 light).
    var surfaceBright: MaterialColor {
        isDark ? blend(surfaceContainerHighest, onSurface, t: 0.08) : surface
    }

    /// M3 Expressive inverse surface role (N90 dark / N20 light).
    var inverseSurface: MaterialColor {
        onSurface
    }

    /// M3 Expressive inverse on-surface role (N20 dark / N95 light).
    var inverseOnSurface: MaterialColor {
        surfaceContainerLow
    }

    // Primary Fixed (P90 / P80 / P10 / P30 invariant across light & dark)
    var primaryFixed: MaterialColor {
        isDark ? onPrimaryContainer : primaryContainer
    }
    var primaryFixedDim: MaterialColor {
        isDark ? primary : inversePrimary
    }
    var onPrimaryFixed: MaterialColor {
        isDark ? blend(onPrimary, MaterialColor("#000000"), t: 0.45) : onPrimaryContainer
    }
    var onPrimaryFixedVariant: MaterialColor {
        isDark ? primaryContainer : blend(primary, onPrimaryContainer, t: 0.35)
    }

    // Secondary Fixed (S90 / S80 / S10 / S30 invariant across light & dark)
    var secondaryFixed: MaterialColor {
        isDark ? onSecondaryContainer : secondaryContainer
    }
    var secondaryFixedDim: MaterialColor {
        isDark ? secondary : blend(secondaryContainer, secondary, t: 0.35)
    }
    var onSecondaryFixed: MaterialColor {
        isDark ? blend(onSecondary, MaterialColor("#000000"), t: 0.45) : onSecondaryContainer
    }
    var onSecondaryFixedVariant: MaterialColor {
        isDark ? secondaryContainer : blend(secondary, onSecondaryContainer, t: 0.35)
    }

    // Tertiary Fixed (T90 / T80 / T10 / T30 invariant across light & dark)
    var tertiaryFixed: MaterialColor {
        isDark ? onTertiaryContainer : tertiaryContainer
    }
    var tertiaryFixedDim: MaterialColor {
        isDark ? tertiary : blend(tertiaryContainer, tertiary, t: 0.35)
    }
    var onTertiaryFixed: MaterialColor {
        isDark ? blend(onTertiary, MaterialColor("#000000"), t: 0.45) : onTertiaryContainer
    }
    var onTertiaryFixedVariant: MaterialColor {
        isDark ? tertiaryContainer : blend(tertiary, onTertiaryContainer, t: 0.35)
    }
}

// MARK: - Stock fallback palettes

public extension MaterialPalette {
    /// Default dark palette (DMS "Purple" dark stock theme) for previews and defaults.
    static let defaultDark = MaterialPalette(
        name: "Purple",
        isDark: true,
        primary: MaterialColor("#D0BCFF"),
        onPrimary: MaterialColor("#381E72"),
        primaryContainer: MaterialColor("#4F378B"),
        onPrimaryContainer: MaterialColor("#EADDFF"),
        inversePrimary: MaterialColor("#6750A4"),
        secondary: MaterialColor("#CCC2DC"),
        onSecondary: MaterialColor("#332D41"),
        secondaryContainer: MaterialColor("#4A4458"),
        onSecondaryContainer: MaterialColor("#E8DEF8"),
        tertiary: MaterialColor("#EFB8C8"),
        onTertiary: MaterialColor("#492532"),
        tertiaryContainer: MaterialColor("#633B48"),
        onTertiaryContainer: MaterialColor("#FFD8E4"),
        surface: MaterialColor("#141218"),
        onSurface: MaterialColor("#E6E0E9"),
        surfaceVariant: MaterialColor("#49454E"),
        onSurfaceVariant: MaterialColor("#CAC4CF"),
        surfaceTint: MaterialColor("#D0BCFF"),
        surfaceContainerLowest: MaterialColor("#100E14"),
        surfaceContainerLow: MaterialColor("#1D1B20"),
        surfaceContainer: MaterialColor("#211F24"),
        surfaceContainerHigh: MaterialColor("#2B292F"),
        surfaceContainerHighest: MaterialColor("#36343A"),
        background: MaterialColor("#141218"),
        onBackground: MaterialColor("#E6E0E9"),
        outline: MaterialColor("#948F99"),
        outlineVariant: MaterialColor("#49454E")
    )

    /// Default light palette (DMS "Purple" light stock theme) for previews and defaults.
    static let defaultLight = MaterialPalette(
        name: "Purple",
        isDark: false,
        primary: MaterialColor("#6750A4"),
        onPrimary: MaterialColor("#FFFFFF"),
        primaryContainer: MaterialColor("#EADDFF"),
        onPrimaryContainer: MaterialColor("#21005D"),
        inversePrimary: MaterialColor("#D0BCFF"),
        secondary: MaterialColor("#625B71"),
        onSecondary: MaterialColor("#FFFFFF"),
        secondaryContainer: MaterialColor("#E8DEF8"),
        onSecondaryContainer: MaterialColor("#1D192B"),
        tertiary: MaterialColor("#7D5260"),
        onTertiary: MaterialColor("#FFFFFF"),
        tertiaryContainer: MaterialColor("#FFD8E4"),
        onTertiaryContainer: MaterialColor("#31111D"),
        surface: MaterialColor("#FEF7FF"),
        onSurface: MaterialColor("#1D1B20"),
        surfaceVariant: MaterialColor("#E7E0EC"),
        onSurfaceVariant: MaterialColor("#49454E"),
        surfaceTint: MaterialColor("#6750A4"),
        surfaceContainerLowest: MaterialColor("#FFFFFF"),
        surfaceContainerLow: MaterialColor("#F7F2FA"),
        surfaceContainer: MaterialColor("#F3EDF7"),
        surfaceContainerHigh: MaterialColor("#ECE6F0"),
        surfaceContainerHighest: MaterialColor("#E6E0E9"),
        background: MaterialColor("#FEF7FF"),
        onBackground: MaterialColor("#1D1B20"),
        outline: MaterialColor("#79747E"),
        outlineVariant: MaterialColor("#CAC4D0")
    )
}
