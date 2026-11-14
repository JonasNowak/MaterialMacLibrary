import Foundation

/// Material Design 3 corner radius tokens and strength scaling.
public struct MaterialShapeTokens: Sendable, Codable, Equatable {
    public var strength: Int // 0 to 100, default 50 = 1.0x
    public var fixedRadius: Double // < 0 means use scaled tokens

    public init(strength: Int = 50, fixedRadius: Double = -1.0) {
        self.strength = min(100, max(0, strength))
        self.fixedRadius = fixedRadius
    }

    /// Scale multiplier derived from `strength` (`scale = normalizeStrength(strength) / 50.0`).
    public var scale: Double {
        Double(min(100, max(0, strength))) / 50.0
    }

    public func scaled(_ base: Double) -> Double {
        if fixedRadius >= 0 {
            return fixedRadius
        }
        return round(base * scale * 100.0) / 100.0
    }

    public var xxs: Double { scaled(2.0) }
    public var xs: Double { scaled(4.0) }
    public var s: Double { scaled(8.0) }
    public var m: Double { scaled(12.0) }
    public var l: Double { scaled(16.0) }
    public var lIncreased: Double { scaled(20.0) }
    public var xl: Double { scaled(28.0) }
    public var xlIncreased: Double { scaled(32.0) }
    public var xxl: Double { scaled(48.0) }
    public var full: Double { fixedRadius >= 0 ? fixedRadius : 9999.0 }
}

/// Material Design 3 cubic Bezier spline control points.
public struct MaterialBezierCurve: Sendable, Codable, Equatable {
    public let name: String
    public let controlPoints: [Double]

    public var c1x: Double { controlPoints.count >= 4 ? controlPoints[0] : 0.2 }
    public var c1y: Double { controlPoints.count >= 4 ? controlPoints[1] : 0.0 }
    /// Second control point. Single-segment curves (4 or 6 points, the shapes DMS consumes)
    /// read `controlPoints[2]`/`[3]` exactly like DMS `M3BezierCurve`; longer multi-segment
    /// curves (e.g. the 12-point `emphasized`) report the terminal segment's control point so
    /// the curve resolves to its end point (1.0, 1.0).
    public var c2x: Double {
        guard controlPoints.count >= 4 else { return 0.0 }
        return controlPoints.count > 6 ? controlPoints[controlPoints.count - 2] : controlPoints[2]
    }
    public var c2y: Double {
        guard controlPoints.count >= 4 else { return 1.0 }
        return controlPoints.count > 6 ? controlPoints[controlPoints.count - 1] : controlPoints[3]
    }

    public init(name: String, controlPoints: [Double]) {
        self.name = name
        self.controlPoints = controlPoints
    }

    public static let emphasized = MaterialBezierCurve(
        name: "emphasized",
        controlPoints: [0.05, 0.0, 0.133333, 0.06, 0.166667, 0.4, 0.208333, 0.82, 0.25, 1.0, 1.0, 1.0]
    )
    public static let emphasizedDecel = MaterialBezierCurve(
        name: "emphasizedDecel",
        controlPoints: [0.05, 0.7, 0.1, 1.0, 1.0, 1.0]
    )
    public static let emphasizedAccel = MaterialBezierCurve(
        name: "emphasizedAccel",
        controlPoints: [0.3, 0.0, 0.8, 0.15, 1.0, 1.0]
    )
    public static let standard = MaterialBezierCurve(
        name: "standard",
        controlPoints: [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]
    )
    public static let standardDecel = MaterialBezierCurve(
        name: "standardDecel",
        controlPoints: [0.0, 0.0, 0.0, 1.0, 1.0, 1.0]
    )
    public static let standardAccel = MaterialBezierCurve(
        name: "standardAccel",
        controlPoints: [0.3, 0.0, 1.0, 1.0, 1.0, 1.0]
    )
}

/// Material Design 3 motion durations and spring constants.
public struct MaterialMotionTokens: Sendable, Codable, Equatable {
    public var animationSpeed: Double // 0.1 to 3.0, default 1.0
    public var reducedMotion: Bool

    public init(animationSpeed: Double = 1.0, reducedMotion: Bool = false) {
        self.animationSpeed = max(0.0, min(3.0, animationSpeed))
        self.reducedMotion = reducedMotion
    }

    private func scaleDuration(_ baseSeconds: Double) -> Double {
        if reducedMotion || animationSpeed <= 0.01 {
            return 0.0
        }
        return baseSeconds / animationSpeed
    }

    /// 200ms base duration
    public var durShort: Double { scaleDuration(0.200) }
    /// 450ms base duration
    public var durMed: Double { scaleDuration(0.450) }
    /// 600ms base duration
    public var durLong: Double { scaleDuration(0.600) }
    /// 180ms settings navigation duration
    public var settingsNavigationStateDuration: Double { scaleDuration(0.180) }
    /// 200ms settings ripple duration
    public var settingsNavigationRippleDuration: Double { scaleDuration(0.200) }
    /// 80px slide translation distance
    public var slidePx: Double { reducedMotion ? 0.0 : 80.0 }
}

/// Material Design 3 typography hierarchy and scaling.
public struct MaterialTypographyTokens: Sendable, Codable, Equatable {
    public var fontFamilyUI: String
    public var fontFamilyMono: String
    public var fontFamilyDisplay: String
    public var fontFamilyHand: String
    public var fontFamilyStylistic: String
    public var fontFamilySymbols: String
    public var fontScale: Double

    public init(
        fontFamilyUI: String = "Google Sans Flex",
        fontFamilyMono: String = "Fira Code",
        fontFamilyDisplay: String = "DM Serif Display",
        fontFamilyHand: String = "Gochi Hand",
        fontFamilyStylistic: String = "Notable",
        fontFamilySymbols: String = "Material Symbols Rounded",
        fontScale: Double = 1.0
    ) {
        self.fontFamilyUI = fontFamilyUI
        self.fontFamilyMono = fontFamilyMono
        self.fontFamilyDisplay = fontFamilyDisplay
        self.fontFamilyHand = fontFamilyHand
        self.fontFamilyStylistic = fontFamilyStylistic
        self.fontFamilySymbols = fontFamilySymbols
        self.fontScale = max(0.75, min(1.5, fontScale))
    }

    public func scaledSize(_ basePt: Double) -> Double {
        round(basePt * fontScale * 10.0) / 10.0
    }
}

/// Surface glassmorphism, opacity, blur, and border customization.
public struct MaterialSurfaceTokens: Sendable, Codable, Equatable {
    public var surfaceOpacity: Double // 0.0 .. 1.0 (default 0.85)
    public var popupTransparency: Double // 0.0 .. 1.0 (default 0.92)
    public var floatingWindowTransparency: Double // 0.0 .. 1.0 (default 0.90)
    public var blurRadius: Int // 0 .. 64 (default 24)
    public var borderWidth: Double // 0.0 .. 4.0 (default 1.0)
    public var outlineOpacity: Double // 0.0 .. 1.0 (default 0.12)

    public init(
        surfaceOpacity: Double = 0.85,
        popupTransparency: Double = 0.92,
        floatingWindowTransparency: Double = 0.90,
        blurRadius: Int = 24,
        borderWidth: Double = 1.0,
        outlineOpacity: Double = 0.12
    ) {
        self.surfaceOpacity = max(0.0, min(1.0, surfaceOpacity))
        self.popupTransparency = max(0.0, min(1.0, popupTransparency))
        self.floatingWindowTransparency = max(0.0, min(1.0, floatingWindowTransparency))
        self.blurRadius = max(0, min(64, blurRadius))
        self.borderWidth = max(0.0, min(4.0, borderWidth))
        self.outlineOpacity = max(0.0, min(1.0, outlineOpacity))
    }
}

/// Elevation shadow customization.
public struct MaterialShadowTokens: Sendable, Codable, Equatable {
    public var enabled: Bool
    public var blurRadius: Double // default 24.0
    public var offsetY: Double // default 8.0
    public var opacity: Double // default 0.35
    public var colorHex: String // default "#000000"

    public init(
        enabled: Bool = true,
        blurRadius: Double = 24.0,
        offsetY: Double = 8.0,
        opacity: Double = 0.35,
        colorHex: String = "#000000"
    ) {
        self.enabled = enabled
        self.blurRadius = max(0.0, min(80.0, blurRadius))
        self.offsetY = max(-24.0, min(32.0, offsetY))
        self.opacity = max(0.0, min(1.0, opacity))
        self.colorHex = colorHex
    }
}

/// Dynamic 16-color ANSI terminal palette.
public struct MaterialDank16Palette: Sendable, Codable, Equatable {
    public let colors: [MaterialColor] // 16 ANSI colors (0..15)
    public let background: MaterialColor
    public let foreground: MaterialColor
    public let cursor: MaterialColor

    public init(colors: [MaterialColor], background: MaterialColor, foreground: MaterialColor, cursor: MaterialColor) {
        self.colors = colors
        self.background = background
        self.foreground = foreground
        self.cursor = cursor
    }

    /// Sensible default dark ANSI palette (16 colors) for previews and defaults.
    public static let `default` = MaterialDank16Palette(
        colors: [
            MaterialColor("#100E14"), MaterialColor("#F38BA8"), MaterialColor("#A6E3A1"),
            MaterialColor("#F9E2AF"), MaterialColor("#89B4FA"), MaterialColor("#F5C2E7"),
            MaterialColor("#94E2D5"), MaterialColor("#E6E0E9"), MaterialColor("#948F99"),
            MaterialColor("#F38BA8"), MaterialColor("#A6E3A1"), MaterialColor("#F9E2AF"),
            MaterialColor("#89B4FA"), MaterialColor("#F5C2E7"), MaterialColor("#94E2D5"),
            MaterialColor("#FFFFFF"),
        ],
        background: MaterialColor("#141218"),
        foreground: MaterialColor("#E6E0E9"),
        cursor: MaterialColor("#D0BCFF")
    )
}

/// Matugen scheme algorithm variants.
public enum MaterialMatugenScheme: String, Sendable, Codable, CaseIterable {
    case tonalSpot = "scheme-tonal-spot"
    case vibrant = "scheme-vibrant"
    case expressive = "scheme-expressive"
    case fidelity = "scheme-fidelity"
    case monochrome = "scheme-monochrome"
    case neutral = "scheme-neutral"

    public var displayName: String {
        switch self {
        case .tonalSpot: return "Tonal Spot (Default)"
        case .vibrant: return "Vibrant"
        case .expressive: return "Expressive"
        case .fidelity: return "Fidelity"
        case .monochrome: return "Monochrome"
        case .neutral: return "Neutral"
        }
    }
}

/// Visual corner style for container surfaces (capsule / gothic / rounded / square).
public enum MaterialCornerStyle: String, Sendable, Codable, CaseIterable, Identifiable {
    case capsule = "capsule"
    case gothic = "gothic"
    case rounded = "rounded"
    case square = "square"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .capsule: return "Capsule"
        case .gothic: return "Gothic"
        case .rounded: return "Rounded"
        case .square: return "Square"
        }
    }

    public var subtitle: String {
        switch self {
        case .capsule: return "Full-radius pill capsule per M3 Expressive"
        case .gothic: return "Concave fillet arcs bridging into screen bezel"
        case .rounded: return "Continuous uniform rounded corners"
        case .square: return "Sharp 90° right angles (edge-flush)"
        }
    }

    public var icon: String {
        switch self {
        case .capsule: return "capsule"
        case .gothic: return "arrow.up.and.line.horizontal.and.arrow.down"
        case .rounded: return "square.dashed"
        case .square: return "square"
        }
    }
}
