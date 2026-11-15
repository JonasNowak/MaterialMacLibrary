import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Material Design 3 Expressive corner radius tokens, optical nesting, and interactive morphing scales.
public struct MaterialShapeTokens: Sendable, Codable, Equatable {
    public var strength: Int // 0 to 100, default 50 = 1.0x
    public var fixedRadius: Double // < 0 means use scaled tokens
    /// M3 Expressive press-state corner multiplier (default 0.65 — squishes pill/rounded corners on press).
    public var pressedCornerScale: Double
    /// M3 Expressive selected/toggled corner multiplier (default 0.50 — morphs circular/pill into squircle).
    public var selectedCornerScale: Double

    public init(
        strength: Int = 50,
        fixedRadius: Double = -1.0,
        pressedCornerScale: Double = 0.65,
        selectedCornerScale: Double = 0.50
    ) {
        self.strength = min(100, max(0, strength))
        self.fixedRadius = fixedRadius
        self.pressedCornerScale = min(2.0, max(0.0, pressedCornerScale))
        self.selectedCornerScale = min(2.0, max(0.0, selectedCornerScale))
    }

    private enum CodingKeys: String, CodingKey {
        case strength, fixedRadius, pressedCornerScale, selectedCornerScale
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let strength = try c.decodeIfPresent(Int.self, forKey: .strength) ?? 50
        let fixedRadius = try c.decodeIfPresent(Double.self, forKey: .fixedRadius) ?? -1.0
        let pressed = try c.decodeIfPresent(Double.self, forKey: .pressedCornerScale) ?? 0.65
        let selected = try c.decodeIfPresent(Double.self, forKey: .selectedCornerScale) ?? 0.50
        self.init(
            strength: strength,
            fixedRadius: fixedRadius,
            pressedCornerScale: pressed,
            selectedCornerScale: selected
        )
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

    /// Interpolates between the resting scaled radius (`progress = 0`) and a morphed target radius (`progress = 1`).
    public func morphedRadius(base: Double, progress: Double, targetScale: Double? = nil) -> Double {
        let resting = scaled(base)
        if fixedRadius >= 0 {
            return fixedRadius
        }
        let mult = targetScale ?? pressedCornerScale
        let target = round(resting * mult * 100.0) / 100.0
        let t = min(1.0, max(0.0, progress))
        return round((resting + (target - resting) * t) * 100.0) / 100.0
    }

    /// M3 Expressive optical concentric inner corner radius (`max(0, outerRadius - padding)`).
    public func opticalInnerRadius(outerRadius: Double, padding: Double) -> Double {
        max(0.0, outerRadius - max(0.0, padding))
    }

    public var none: Double { 0.0 }
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

/// Material Design 3 Expressive physics spring specification (`dampingRatio` ζ and `stiffness` k).
/// Spatial springs have `dampingRatio < 1.0` (allowing natural bounce/overshoot);
/// Effects springs have `dampingRatio == 1.0` (critically damped, never overshooting).
public struct MaterialSpringSpec: Sendable, Codable, Equatable {
    public let dampingRatio: Double
    public let stiffness: Double

    public init(dampingRatio: Double, stiffness: Double) {
        self.dampingRatio = max(0.05, min(2.0, dampingRatio))
        self.stiffness = max(1.0, stiffness)
    }

    /// Whether this spring is underdamped and can overshoot its target value.
    public var allowsOvershoot: Bool {
        dampingRatio < 1.0
    }

    /// Undamped natural period (`2π / √k`) in seconds for unit mass.
    public var response: Double {
        2.0 * .pi / sqrt(max(1.0, stiffness))
    }

    /// Critical damping coefficient (`2√k`) for unit mass.
    public var criticalDampingCoefficient: Double {
        2.0 * sqrt(max(1.0, stiffness))
    }

    /// Viscous damping coefficient (`c = ζ * 2√k`) for unit mass.
    public var damping: Double {
        dampingRatio * criticalDampingCoefficient
    }

    /// Scales the spring stiffness by `speed²` so natural frequency scales linearly with `speed`.
    public func scaled(by speed: Double) -> MaterialSpringSpec {
        let clampedSpeed = max(0.1, min(3.0, speed))
        return MaterialSpringSpec(
            dampingRatio: dampingRatio,
            stiffness: stiffness * clampedSpeed * clampedSpeed
        )
    }

    #if canImport(SwiftUI)
    /// Native SwiftUI `Spring` representation of this M3 physics token.
    public var swiftUISpring: Spring {
        Spring(response: response, dampingRatio: dampingRatio)
    }

    /// Native SwiftUI `Animation` driven by this spring token.
    public var animation: Animation {
        .spring(swiftUISpring)
    }

    /// Returns a SwiftUI `Animation` respecting `animationSpeed` and `reducedMotion`.
    public func animation(speed: Double = 1.0, reducedMotion: Bool = false) -> Animation {
        if reducedMotion || speed <= 0.01 {
            return .linear(duration: 0.0)
        }
        return scaled(by: speed).animation
    }
    #endif
}

/// Material Design 3 Expressive motion scheme presets (`MotionScheme.expressive()` vs `MotionScheme.standard()`).
public enum MaterialMotionScheme: String, Sendable, Codable, Equatable, CaseIterable {
    /// M3 Expressive default scheme: energetic, playful spatial springs with subtle overshoot.
    case expressive = "expressive"
    /// M3 Standard scheme: utilitarian, high-damping springs with minimal bounce.
    case standard = "standard"

    /// Small component spatial spring (switches, menus, icon/corner morphs).
    public var fastSpatial: MaterialSpringSpec {
        switch self {
        case .expressive: return MaterialSpringSpec(dampingRatio: 0.6, stiffness: 800)
        case .standard:   return MaterialSpringSpec(dampingRatio: 0.9, stiffness: 1400)
        }
    }

    /// Default component spatial spring (sheets, cards, tab indicators, popouts).
    public var defaultSpatial: MaterialSpringSpec {
        switch self {
        case .expressive: return MaterialSpringSpec(dampingRatio: 0.8, stiffness: 380)
        case .standard:   return MaterialSpringSpec(dampingRatio: 0.9, stiffness: 700)
        }
    }

    /// Large / full-screen layout spatial spring.
    public var slowSpatial: MaterialSpringSpec {
        switch self {
        case .expressive: return MaterialSpringSpec(dampingRatio: 0.8, stiffness: 200)
        case .standard:   return MaterialSpringSpec(dampingRatio: 0.9, stiffness: 300)
        }
    }

    /// Fast non-spatial effects spring (small color/alpha transitions; critically damped).
    public var fastEffects: MaterialSpringSpec {
        MaterialSpringSpec(dampingRatio: 1.0, stiffness: 3800)
    }

    /// Default non-spatial effects spring (standard color/opacity transitions; critically damped).
    public var defaultEffects: MaterialSpringSpec {
        MaterialSpringSpec(dampingRatio: 1.0, stiffness: 1600)
    }

    /// Slow non-spatial effects spring (large surface color/fade transitions; critically damped).
    public var slowEffects: MaterialSpringSpec {
        MaterialSpringSpec(dampingRatio: 1.0, stiffness: 800)
    }
}

/// Material Design 3 Expressive motion durations and physics spring tokens.
public struct MaterialMotionTokens: Sendable, Codable, Equatable {
    public var animationSpeed: Double // 0.1 to 3.0, default 1.0
    public var reducedMotion: Bool
    public var scheme: MaterialMotionScheme

    public init(
        animationSpeed: Double = 1.0,
        reducedMotion: Bool = false,
        scheme: MaterialMotionScheme = .expressive
    ) {
        self.animationSpeed = max(0.0, min(3.0, animationSpeed))
        self.reducedMotion = reducedMotion
        self.scheme = scheme
    }

    private enum CodingKeys: String, CodingKey {
        case animationSpeed, reducedMotion, scheme
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let speed = try c.decodeIfPresent(Double.self, forKey: .animationSpeed) ?? 1.0
        let reduced = try c.decodeIfPresent(Bool.self, forKey: .reducedMotion) ?? false
        let scheme = try c.decodeIfPresent(MaterialMotionScheme.self, forKey: .scheme) ?? .expressive
        self.init(animationSpeed: speed, reducedMotion: reduced, scheme: scheme)
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

    // MARK: - M3 Expressive Spring Physics Tokens

    public var fastSpatial: MaterialSpringSpec {
        scheme.fastSpatial.scaled(by: max(0.1, animationSpeed))
    }

    public var defaultSpatial: MaterialSpringSpec {
        scheme.defaultSpatial.scaled(by: max(0.1, animationSpeed))
    }

    public var slowSpatial: MaterialSpringSpec {
        scheme.slowSpatial.scaled(by: max(0.1, animationSpeed))
    }

    public var fastEffects: MaterialSpringSpec {
        scheme.fastEffects.scaled(by: max(0.1, animationSpeed))
    }

    public var defaultEffects: MaterialSpringSpec {
        scheme.defaultEffects.scaled(by: max(0.1, animationSpeed))
    }

    public var slowEffects: MaterialSpringSpec {
        scheme.slowEffects.scaled(by: max(0.1, animationSpeed))
    }

    #if canImport(SwiftUI)
    public var fastSpatialAnimation: Animation {
        scheme.fastSpatial.animation(speed: animationSpeed, reducedMotion: reducedMotion)
    }

    public var defaultSpatialAnimation: Animation {
        scheme.defaultSpatial.animation(speed: animationSpeed, reducedMotion: reducedMotion)
    }

    public var slowSpatialAnimation: Animation {
        scheme.slowSpatial.animation(speed: animationSpeed, reducedMotion: reducedMotion)
    }

    public var fastEffectsAnimation: Animation {
        scheme.fastEffects.animation(speed: animationSpeed, reducedMotion: reducedMotion)
    }

    public var defaultEffectsAnimation: Animation {
        scheme.defaultEffects.animation(speed: animationSpeed, reducedMotion: reducedMotion)
    }

    public var slowEffectsAnimation: Animation {
        scheme.slowEffects.animation(speed: animationSpeed, reducedMotion: reducedMotion)
    }
    #endif
}

/// The 15 canonical Material Design 3 type scale roles.
/// In M3 Expressive, each role has both a baseline variant and an emphasized variant (30 styles total).
public enum MaterialTypeScaleRole: String, Sendable, Codable, Equatable, CaseIterable {
    case displayLarge
    case displayMedium
    case displaySmall
    case headlineLarge
    case headlineMedium
    case headlineSmall
    case titleLarge
    case titleMedium
    case titleSmall
    case bodyLarge
    case bodyMedium
    case bodySmall
    case labelLarge
    case labelMedium
    case labelSmall
}

/// Resolved typography metrics and variable-font axes for a single M3 Expressive type style.
public struct MaterialTypeStyle: Sendable, Codable, Equatable {
    public let role: MaterialTypeScaleRole
    public let isEmphasized: Bool
    /// Font size in points (already scaled by `fontScale`).
    public let size: Double
    /// Line height in points (already scaled by `fontScale`).
    public let lineHeight: Double
    /// Letter spacing (tracking) in points.
    public let tracking: Double
    /// Numeric font weight (100...900). Emphasized styles shift heavier for editorial hierarchy.
    public let weightNumeric: Int
    /// Variable font width axis (`wdth`, 100 = normal, >100 = expanded).
    public let widthAxis: Double
    /// Variable font grade axis (`GRAD`, 0 = baseline, +25 = emphasized).
    public let gradeAxis: Double
    /// Variable font roundness axis (`ROND`, 100 = full M3 Expressive roundness).
    public let roundAxis: Double

    public init(
        role: MaterialTypeScaleRole,
        isEmphasized: Bool,
        size: Double,
        lineHeight: Double,
        tracking: Double,
        weightNumeric: Int,
        widthAxis: Double = 100.0,
        gradeAxis: Double = 0.0,
        roundAxis: Double = 100.0
    ) {
        self.role = role
        self.isEmphasized = isEmphasized
        self.size = size
        self.lineHeight = lineHeight
        self.tracking = tracking
        self.weightNumeric = weightNumeric
        self.widthAxis = widthAxis
        self.gradeAxis = gradeAxis
        self.roundAxis = roundAxis
    }

    #if canImport(SwiftUI)
    /// Maps `weightNumeric` to a SwiftUI `Font.Weight`.
    public var swiftUIWeight: Font.Weight {
        switch weightNumeric {
        case ..<250: return .ultraLight
        case 250..<350: return .light
        case 350..<450: return .regular
        case 450..<550: return .medium
        case 550..<650: return .semibold
        case 650..<750: return .bold
        case 750..<850: return .heavy
        default: return .black
        }
    }
    #endif
}

/// Material Design 3 Expressive typography hierarchy, 30-style type scale (15 baseline + 15 emphasized), and scaling.
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

    /// Resolves a baseline or M3 Expressive emphasized `MaterialTypeStyle` for the given role.
    public func style(for role: MaterialTypeScaleRole, emphasized: Bool = false) -> MaterialTypeStyle {
        let baseSize: Double
        let baseLineHeight: Double
        let tracking: Double
        let baseWeight: Int
        let emphasizedWeight: Int
        let emphasizedWidth: Double

        switch role {
        case .displayLarge:
            baseSize = 57; baseLineHeight = 64; tracking = -0.25; baseWeight = 400; emphasizedWeight = 600; emphasizedWidth = 108
        case .displayMedium:
            baseSize = 45; baseLineHeight = 52; tracking = 0.0;   baseWeight = 400; emphasizedWeight = 600; emphasizedWidth = 106
        case .displaySmall:
            baseSize = 36; baseLineHeight = 44; tracking = 0.0;   baseWeight = 400; emphasizedWeight = 600; emphasizedWidth = 104
        case .headlineLarge:
            baseSize = 32; baseLineHeight = 40; tracking = 0.0;   baseWeight = 400; emphasizedWeight = 600; emphasizedWidth = 104
        case .headlineMedium:
            baseSize = 28; baseLineHeight = 36; tracking = 0.0;   baseWeight = 400; emphasizedWeight = 600; emphasizedWidth = 102
        case .headlineSmall:
            baseSize = 24; baseLineHeight = 32; tracking = 0.0;   baseWeight = 400; emphasizedWeight = 600; emphasizedWidth = 102
        case .titleLarge:
            baseSize = 22; baseLineHeight = 28; tracking = 0.0;   baseWeight = 400; emphasizedWeight = 600; emphasizedWidth = 100
        case .titleMedium:
            baseSize = 16; baseLineHeight = 24; tracking = 0.15;  baseWeight = 500; emphasizedWeight = 700; emphasizedWidth = 100
        case .titleSmall:
            baseSize = 14; baseLineHeight = 20; tracking = 0.10;  baseWeight = 500; emphasizedWeight = 700; emphasizedWidth = 100
        case .bodyLarge:
            baseSize = 16; baseLineHeight = 24; tracking = 0.50;  baseWeight = 400; emphasizedWeight = 500; emphasizedWidth = 100
        case .bodyMedium:
            baseSize = 14; baseLineHeight = 20; tracking = 0.25;  baseWeight = 400; emphasizedWeight = 500; emphasizedWidth = 100
        case .bodySmall:
            baseSize = 12; baseLineHeight = 16; tracking = 0.40;  baseWeight = 400; emphasizedWeight = 500; emphasizedWidth = 100
        case .labelLarge:
            baseSize = 14; baseLineHeight = 20; tracking = 0.10;  baseWeight = 500; emphasizedWeight = 700; emphasizedWidth = 100
        case .labelMedium:
            baseSize = 12; baseLineHeight = 16; tracking = 0.50;  baseWeight = 500; emphasizedWeight = 700; emphasizedWidth = 100
        case .labelSmall:
            baseSize = 11; baseLineHeight = 16; tracking = 0.50;  baseWeight = 500; emphasizedWeight = 700; emphasizedWidth = 100
        }

        return MaterialTypeStyle(
            role: role,
            isEmphasized: emphasized,
            size: scaledSize(baseSize),
            lineHeight: scaledSize(baseLineHeight),
            tracking: tracking,
            weightNumeric: emphasized ? emphasizedWeight : baseWeight,
            widthAxis: emphasized ? emphasizedWidth : 100.0,
            gradeAxis: emphasized ? 25.0 : 0.0,
            roundAxis: 100.0
        )
    }

    /// All 15 baseline M3 type scale styles.
    public var allBaselineStyles: [MaterialTypeStyle] {
        MaterialTypeScaleRole.allCases.map { style(for: $0, emphasized: false) }
    }

    /// All 15 M3 Expressive emphasized type scale styles.
    public var allEmphasizedStyles: [MaterialTypeStyle] {
        MaterialTypeScaleRole.allCases.map { style(for: $0, emphasized: true) }
    }

    /// All 30 M3 Expressive type scale styles (15 baseline + 15 emphasized).
    public var allStyles: [MaterialTypeStyle] {
        allBaselineStyles + allEmphasizedStyles
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
