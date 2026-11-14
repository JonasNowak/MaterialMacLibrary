import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(AppKit)
import AppKit
#endif

/// A Material Design 3 color token: RGBA components plus canonical hex string.
/// Codable accepts either the full object (`{"red":…,"green":…,"blue":…,"alpha":…,"hex":"#RRGGBB"}`),
/// a DMS-style object (`{"hex":"#RRGGBB"}`), or a plain `#RRGGBB` / `#RRGGBBAA` string.
public struct MaterialColor: Sendable, Codable, Equatable, Hashable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    public let hex: String

    /// Creates a color from a hex string (`#RGB`, `#RRGGBB`, `#RRGGBBAA`, with or without `#`).
    public init(_ hex: String, alpha: Double = 1.0) {
        var clean = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if !clean.hasPrefix("#") {
            clean = "#" + clean
        }
        var body = clean
        body.removeFirst()
        if body.count == 3 {
            let r = body[body.startIndex]
            let g = body[body.index(body.startIndex, offsetBy: 1)]
            let b = body[body.index(body.startIndex, offsetBy: 2)]
            body = "\(r)\(r)\(g)\(g)\(b)\(b)"
        }
        var parsedAlpha = min(1.0, max(0.0, alpha))
        var rgb = body
        if body.count >= 8, let hexNum = UInt64(body.prefix(8), radix: 16) {
            parsedAlpha = Double(hexNum & 0xFF) / 255.0
            rgb = String(body.dropLast(2))
        }
        guard rgb.count >= 6, let hexNum = UInt64(rgb.prefix(6), radix: 16) else {
            self.red = 0
            self.green = 0
            self.blue = 0
            self.alpha = parsedAlpha
            self.hex = clean
            return
        }
        self.red = Double((hexNum >> 16) & 0xFF) / 255.0
        self.green = Double((hexNum >> 8) & 0xFF) / 255.0
        self.blue = Double(hexNum & 0xFF) / 255.0
        self.alpha = parsedAlpha
        self.hex = clean
    }

    /// Creates a color from linear 0...1 RGBA components; `hex` is derived canonically.
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        let clamp: (Double) -> Int = { min(255, max(0, Int(round($0 * 255.0)))) }
        let ri = clamp(red)
        let gi = clamp(green)
        let bi = clamp(blue)
        let ai = min(255, max(0, Int(round(min(1.0, max(0.0, alpha)) * 255.0))))
        if ai >= 255 {
            self.hex = String(format: "#%02X%02X%02X", ri, gi, bi)
        } else {
            self.hex = String(format: "#%02X%02X%02X%02X", ri, gi, bi, ai)
        }
        self.red = Double(ri) / 255.0
        self.green = Double(gi) / 255.0
        self.blue = Double(bi) / 255.0
        self.alpha = Double(ai) / 255.0
    }

    public static func from(r: Double, g: Double, b: Double) -> MaterialColor {
        MaterialColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    // MARK: - Codable (full object OR hex string convenience)

    private enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha, hex
    }

    public init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()
        if let string = try? single.decode(String.self) {
            self.init(string)
            return
        }
        let keyed = try decoder.container(keyedBy: CodingKeys.self)
        if let hex = try? keyed.decode(String.self, forKey: .hex) {
            let alpha = try? keyed.decodeIfPresent(Double.self, forKey: .alpha)
            self.init(hex, alpha: alpha ?? 1.0)
            return
        }
        self.init(
            red: try keyed.decode(Double.self, forKey: .red),
            green: try keyed.decode(Double.self, forKey: .green),
            blue: try keyed.decode(Double.self, forKey: .blue),
            alpha: (try? keyed.decodeIfPresent(Double.self, forKey: .alpha)) ?? 1.0
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
        try container.encode(hex, forKey: .hex)
    }

    // MARK: - Platform color bridges

    #if canImport(SwiftUI)
    /// SwiftUI color for this token.
    public var swiftUIColor: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    #endif

    #if canImport(AppKit)
    /// AppKit color for this token.
    public var nsColor: NSColor {
        NSColor(srgbRed: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    #endif
}

#if canImport(SwiftUI)
public extension Color {
    /// Creates a SwiftUI color from a hex string (`#RGB`, `#RRGGBB`, `#RRGGBBAA`, with or without `#`).
    init(hex: String) {
        self = MaterialColor(hex).swiftUIColor
    }
}
#endif
