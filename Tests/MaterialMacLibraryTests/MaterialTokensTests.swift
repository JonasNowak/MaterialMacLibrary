import Testing
import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
import MaterialMacLibrary

@Suite
struct MaterialTokensTests {

    // MARK: - MaterialColor hex parsing

    @Test
    func testMaterialColorHexParsing() {
        let c = MaterialColor("#FF8800")
        #expect(c.hex == "#FF8800")
        #expect(c.red == 1.0)
        #expect(abs(c.green - Double(0x88) / 255.0) <= 1e-9)
        #expect(c.blue == 0.0)
        #expect(c.alpha == 1.0)

        let noPrefix = MaterialColor("00FF00")
        #expect(noPrefix.hex == "#00FF00")
        #expect(noPrefix.green == 1.0)

        let short = MaterialColor("#F80")
        #expect(short.red == 1.0)
        #expect(abs(short.green - Double(0x88) / 255.0) <= 1e-9)
        #expect(short.blue == 0.0)

        let withAlpha = MaterialColor("#FF880080")
        #expect(abs(withAlpha.alpha - Double(0x80) / 255.0) <= 1e-9)
        #expect(withAlpha.red == 1.0)

        let invalid = MaterialColor("not-a-color")
        #expect(invalid.red == 0.0)
        #expect(invalid.green == 0.0)
        #expect(invalid.blue == 0.0)

        let fromRGB = MaterialColor(red: 1.0, green: 0.5333333333, blue: 0.0)
        #expect(fromRGB.hex == "#FF8800")
        #expect(MaterialColor.from(r: 1.0, g: 0.0, b: 0.0).hex == "#FF0000")
    }

    @Test
    func testMaterialColorCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // Canonical encoding carries the full field set
        let data = try encoder.encode(MaterialColor("#D0BCFF"))
        let obj = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(obj["red"] != nil)
        #expect(obj["green"] != nil)
        #expect(obj["blue"] != nil)
        #expect(obj["alpha"] != nil)
        #expect(obj["hex"] as? String == "#D0BCFF")

        // DMS-style object (hex only) decodes
        let dmsStyle = try #require(##"{"hex":"#D0BCFF"}"##.data(using: .utf8))
        let fromDMS = try decoder.decode(MaterialColor.self, from: dmsStyle)
        #expect(fromDMS.hex == "#D0BCFF")
        #expect(abs(fromDMS.red - Double(0xD0) / 255.0) <= 1e-9)

        // Plain string convenience form decodes
        let stringForm = try #require(##""#D0BCFF""##.data(using: .utf8))
        let fromString = try decoder.decode(MaterialColor.self, from: stringForm)
        #expect(fromString == fromDMS)

        // Roundtrip
        let original = MaterialColor("#123456", alpha: 0.5)
        let roundtrip = try decoder.decode(MaterialColor.self, from: try encoder.encode(original))
        #expect(roundtrip == original)
    }

    #if canImport(SwiftUI)
    @Test
    func testMaterialColorBridges() {
        let color = Color(hex: "#FF8800")
        #expect(color == MaterialColor("#FF8800").swiftUIColor)
        let ns = MaterialColor("#FF8800").nsColor.usingColorSpace(.sRGB)
        #expect((ns?.redComponent ?? 0) > 0.99)
    }
    #endif

    // MARK: - MaterialPalette Codable parity with DMS JSON field names

    @Test
    func testMaterialPaletteCodableRoundtrip() throws {
        let hexRoles: [String] = [
            "primary", "onPrimary", "primaryContainer", "onPrimaryContainer", "inversePrimary",
            "secondary", "onSecondary", "secondaryContainer", "onSecondaryContainer",
            "tertiary", "onTertiary", "tertiaryContainer", "onTertiaryContainer",
            "surface", "onSurface", "surfaceVariant", "onSurfaceVariant", "surfaceTint",
            "surfaceContainerLowest", "surfaceContainerLow", "surfaceContainer",
            "surfaceContainerHigh", "surfaceContainerHighest",
            "background", "onBackground", "outline", "outlineVariant",
            "error", "onError", "errorContainer", "onErrorContainer",
            "warning", "onWarning", "warningContainer", "onWarningContainer",
            "info", "onInfo", "infoContainer", "onInfoContainer",
            "success", "onSuccess", "successContainer", "onSuccessContainer",
            "scrim", "shadow"
        ]
        var json: [String: Any] = ["name": "Test", "isDark": true]
        for (i, role) in hexRoles.enumerated() {
            json[role] = ["hex": String(format: "#%02X%02X%02X", (i * 5) % 256, (i * 7) % 256, (i * 11) % 256)]
        }
        let data = try JSONSerialization.data(withJSONObject: json)
        let palette = try JSONDecoder().decode(MaterialPalette.self, from: data)

        #expect(palette.name == "Test")
        #expect(palette.isDark)
        #expect(palette.primary.hex.hasPrefix("#"))
        #expect(palette.surfaceContainerHighest.hex.hasPrefix("#"))
        #expect(palette.onSurfaceVariant.hex.hasPrefix("#"))

        // Re-encode: field names must match DMS JSON keys
        let encoded = try JSONEncoder().encode(palette)
        let encodedObj = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        for key in ["name", "isDark", "primary", "surfaceContainerHighest", "onSurfaceVariant", "outlineVariant", "successContainer", "scrim", "shadow"] {
            #expect(encodedObj[key] != nil, "missing key \(key)")
        }

        // Full roundtrip equality
        let roundtrip = try JSONDecoder().decode(MaterialPalette.self, from: encoded)
        #expect(roundtrip == palette)
    }

    @Test
    func testMaterialPaletteStringColorsAndDefaults() throws {
        let json = try #require(##"{"name":"S","isDark":false,"primary":"#6750A4","onPrimary":"#FFFFFF","primaryContainer":"#EADDFF","onPrimaryContainer":"#21005D","inversePrimary":"#D0BCFF","secondary":"#625B71","onSecondary":"#FFFFFF","secondaryContainer":"#E8DEF8","onSecondaryContainer":"#1D192B","tertiary":"#7D5260","onTertiary":"#FFFFFF","tertiaryContainer":"#FFD8E4","onTertiaryContainer":"#31111D","surface":"#FEF7FF","onSurface":"#1D1B20","surfaceVariant":"#E7E0EC","onSurfaceVariant":"#49454E","surfaceTint":"#6750A4","surfaceContainerLowest":"#FFFFFF","surfaceContainerLow":"#F7F2FA","surfaceContainer":"#F3EDF7","surfaceContainerHigh":"#ECE6F0","surfaceContainerHighest":"#E6E0E9","background":"#FEF7FF","onBackground":"#1D1B20","outline":"#79747E","outlineVariant":"#CAC4D0"}"##.data(using: .utf8))
        let palette = try JSONDecoder().decode(MaterialPalette.self, from: json)
        #expect(palette.primary.hex == "#6750A4")
        #expect(abs(palette.primary.red - Double(0x67) / 255.0) <= 1e-9)
        // Light-mode default for onWarning is white
        #expect(palette.onWarning.hex == "#FFFFFF")
        #expect(palette.scrim.hex == "#000000")
    }

    @Test
    func testDefaultPalettes() {
        #expect(MaterialPalette.defaultDark.isDark)
        #expect(!MaterialPalette.defaultLight.isDark)
        #expect(MaterialPalette.defaultDark.primary.hex == "#D0BCFF")
        #expect(MaterialPalette.defaultLight.primary.hex == "#6750A4")
        #expect(MaterialPalette.defaultDark != MaterialPalette.defaultLight)
    }

    // MARK: - Shape / motion / typography / surface / shadow tokens

    @Test
    func testShapeTokensScaling() throws {
        let def = MaterialShapeTokens()
        #expect(def.strength == 50)
        #expect(def.scale == 1.0)
        #expect(def.scaled(8.0) == 8.0)
        #expect(def.s == 8.0)
        #expect(def.xxl == 48.0)
        #expect(def.full == 9999.0)

        let double_ = MaterialShapeTokens(strength: 100)
        #expect(double_.scale == 2.0)
        #expect(double_.scaled(8.0) == 16.0)

        let zero = MaterialShapeTokens(strength: 0)
        #expect(zero.scaled(8.0) == 0.0)

        let clamped = MaterialShapeTokens(strength: 250)
        #expect(clamped.strength == 100)

        let fixed = MaterialShapeTokens(strength: 50, fixedRadius: 12.0)
        #expect(fixed.scaled(8.0) == 12.0)
        #expect(fixed.full == 12.0)

        // Codable roundtrip
        let tokens = MaterialShapeTokens(strength: 75, fixedRadius: -1)
        let data = try JSONEncoder().encode(tokens)
        let decoded = try JSONDecoder().decode(MaterialShapeTokens.self, from: data)
        #expect(decoded == tokens)
    }

    @Test
    func testMotionTokens() {
        let def = MaterialMotionTokens()
        #expect(def.durShort == 0.2)
        #expect(def.durMed == 0.45)
        #expect(def.durLong == 0.6)
        #expect(def.slidePx == 80.0)

        let fast = MaterialMotionTokens(animationSpeed: 2.0)
        #expect(abs(fast.durShort - 0.1) <= 1e-9)

        let clamped = MaterialMotionTokens(animationSpeed: 99.0)
        #expect(clamped.animationSpeed == 3.0)

        let reduced = MaterialMotionTokens(reducedMotion: true)
        #expect(reduced.durShort == 0.0)
        #expect(reduced.durMed == 0.0)
        #expect(reduced.slidePx == 0.0)
    }

    @Test
    func testTypographyTokens() {
        let def = MaterialTypographyTokens()
        #expect(def.fontScale == 1.0)
        #expect(def.scaledSize(14.0) == 14.0)

        let big = MaterialTypographyTokens(fontScale: 2.0)
        #expect(big.fontScale == 1.5)
        #expect(big.scaledSize(14.0) == 21.0)

        let small = MaterialTypographyTokens(fontScale: 0.1)
        #expect(small.fontScale == 0.75)
        #expect(small.scaledSize(14.0) == 10.5)
    }

    @Test
    func testSurfaceAndShadowTokens() throws {
        let s = MaterialSurfaceTokens(surfaceOpacity: 2.0, blurRadius: 100, borderWidth: 9.0)
        #expect(s.surfaceOpacity == 1.0)
        #expect(s.blurRadius == 64)
        #expect(s.borderWidth == 4.0)

        let sh = MaterialShadowTokens(blurRadius: 999.0, offsetY: -99.0, opacity: 5.0)
        #expect(sh.blurRadius == 80.0)
        #expect(sh.offsetY == -24.0)
        #expect(sh.opacity == 1.0)

        let data = try JSONEncoder().encode(s)
        let decoded = try JSONDecoder().decode(MaterialSurfaceTokens.self, from: data)
        #expect(decoded == s)
    }

    @Test
    func testBezierCurve() {
        let c = MaterialBezierCurve.emphasized
        #expect(c.name == "emphasized")
        #expect(c.c1x == 0.05)
        #expect(c.c2y == 1.0)
        let short = MaterialBezierCurve(name: "x", controlPoints: [0.1, 0.2])
        #expect(short.c1x == 0.2) // fallback
        #expect(short.c2y == 1.0) // fallback
    }

    // MARK: - Enums

    @Test
    func testMaterialCornerStyle() {
        #expect(MaterialCornerStyle.allCases.count == 4)
        #expect(MaterialCornerStyle.capsule.rawValue == "capsule")
        #expect(MaterialCornerStyle.gothic.rawValue == "gothic")
        #expect(MaterialCornerStyle.rounded.rawValue == "rounded")
        #expect(MaterialCornerStyle.square.rawValue == "square")
        #expect(MaterialCornerStyle.capsule.title == "Capsule")
        #expect(MaterialCornerStyle.gothic.title == "Gothic")
        #expect(MaterialCornerStyle.rounded.title == "Rounded")
        #expect(MaterialCornerStyle.square.title == "Square")
        #expect(MaterialCornerStyle.square.id == "square")
        #expect(MaterialCornerStyle.gothic.icon == "arrow.up.and.line.horizontal.and.arrow.down")
    }

    @Test
    func testMatugenScheme() {
        #expect(MaterialMatugenScheme.allCases.count == 6)
        #expect(MaterialMatugenScheme.tonalSpot.rawValue == "scheme-tonal-spot")
        #expect(MaterialMatugenScheme.vibrant.rawValue == "scheme-vibrant")
        #expect(MaterialMatugenScheme.expressive.rawValue == "scheme-expressive")
        #expect(MaterialMatugenScheme.fidelity.rawValue == "scheme-fidelity")
        #expect(MaterialMatugenScheme.monochrome.rawValue == "scheme-monochrome")
        #expect(MaterialMatugenScheme.neutral.rawValue == "scheme-neutral")
        #expect(MaterialMatugenScheme.tonalSpot.displayName == "Tonal Spot (Default)")
    }

    @Test
    func testDank16Palette() throws {
        let d = MaterialDank16Palette.default
        #expect(d.colors.count == 16)
        let data = try JSONEncoder().encode(d)
        let decoded = try JSONDecoder().decode(MaterialDank16Palette.self, from: data)
        #expect(decoded == d)
    }

    // MARK: - MaterialTheme

    @Test
    @MainActor
    func testMaterialTheme() {
        let theme = MaterialTheme(palette: .defaultDark, activeThemeName: "purple")
        #expect(theme.palette == .defaultDark)
        #expect(theme.activeThemeName == "purple")
        #expect(!theme.isLightMode)
        #expect(theme.dank16.colors.count == 16)

        // Computed color properties mirror the palette
        #expect(theme.primary == MaterialPalette.defaultDark.primary.swiftUIColor)
        #expect(theme.surfaceContainer == MaterialPalette.defaultDark.surfaceContainer.swiftUIColor)
        #expect(theme.surfaceContainerHighest == MaterialPalette.defaultDark.surfaceContainerHighest.swiftUIColor)

        // Shape helper scales through shape tokens
        theme.shapeTokens = MaterialShapeTokens(strength: 100)
        #expect(theme.cornerRadius(base: 8) == 16)

        // Surface helpers return usable colors
        let bg = theme.surfaceBackground(cornerRadius: 16, tintStrength: 0.2, opacity: 0.9)
        #expect(bg != .clear)
        let card = theme.cardBackground()
        #expect(card != .clear)

        // Font helper
        let f = theme.font(size: 14, weight: .semibold, mono: true)
        #expect(f != .body)

        // Light mode flips helpers
        theme.isLightMode = true
        #expect(theme.isLightMode)
    }

    @Test
    @MainActor
    func testMaterialThemeEnvironmentKey() {
        let key = MaterialThemeEnvironmentKey.defaultValue
        #expect(key.palette.isDark)
    }
}
