import Foundation
import CoreGraphics

/// All 35 canonical Google Material Design 3 Expressive shapes (`MaterialShapes`).
public enum MaterialExpressiveShape: String, Sendable, Codable, Equatable, CaseIterable, Identifiable {
    case circle
    case square
    case slanted
    case arch
    case fan
    case arrow
    case semiCircle
    case oval
    case pill
    case triangle
    case diamond
    case clamShell
    case pentagon
    case gem
    case sunny
    case verySunny
    case cookie4
    case cookie6
    case cookie7
    case cookie9
    case cookie12
    case ghostish
    case clover4
    case clover8
    case burst
    case softBurst
    case boom
    case softBoom
    case flower
    case puffy
    case puffyDiamond
    case pixelCircle
    case pixelTriangle
    case bun
    case heart

    public var id: String { rawValue }

    /// Official Jetpack Compose `MaterialShapes` identifier.
    public var composeName: String {
        switch self {
        case .circle: return "Circle"
        case .square: return "Square"
        case .slanted: return "Slanted"
        case .arch: return "Arch"
        case .fan: return "Fan"
        case .arrow: return "Arrow"
        case .semiCircle: return "SemiCircle"
        case .oval: return "Oval"
        case .pill: return "Pill"
        case .triangle: return "Triangle"
        case .diamond: return "Diamond"
        case .clamShell: return "ClamShell"
        case .pentagon: return "Pentagon"
        case .gem: return "Gem"
        case .sunny: return "Sunny"
        case .verySunny: return "VerySunny"
        case .cookie4: return "Cookie4Sided"
        case .cookie6: return "Cookie6Sided"
        case .cookie7: return "Cookie7Sided"
        case .cookie9: return "Cookie9Sided"
        case .cookie12: return "Cookie12Sided"
        case .ghostish: return "Ghostish"
        case .clover4: return "Clover4Leaf"
        case .clover8: return "Clover8Leaf"
        case .burst: return "Burst"
        case .softBurst: return "SoftBurst"
        case .boom: return "Boom"
        case .softBoom: return "SoftBoom"
        case .flower: return "Flower"
        case .puffy: return "Puffy"
        case .puffyDiamond: return "PuffyDiamond"
        case .pixelCircle: return "PixelCircle"
        case .pixelTriangle: return "PixelTriangle"
        case .bun: return "Bun"
        case .heart: return "Heart"
        }
    }

    /// Resolves either a short name (`"cookie4"`) or a Compose name (`"Cookie4Sided"`),
    /// defaulting to `.circle` for unknown names.
    public static func resolve(_ name: String) -> MaterialExpressiveShape {
        let cleaned = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .lowercased()

        switch cleaned {
        case "circle": return .circle
        case "square": return .square
        case "slanted": return .slanted
        case "arch": return .arch
        case "fan": return .fan
        case "arrow": return .arrow
        case "semicircle": return .semiCircle
        case "oval": return .oval
        case "pill": return .pill
        case "triangle": return .triangle
        case "diamond": return .diamond
        case "clamshell": return .clamShell
        case "pentagon": return .pentagon
        case "gem": return .gem
        case "sunny": return .sunny
        case "verysunny": return .verySunny
        case "cookie4", "cookie4sided": return .cookie4
        case "cookie6", "cookie6sided": return .cookie6
        case "cookie7", "cookie7sided": return .cookie7
        case "cookie9", "cookie9sided": return .cookie9
        case "cookie12", "cookie12sided": return .cookie12
        case "ghostish": return .ghostish
        case "clover4", "clover4leaf": return .clover4
        case "clover8", "clover8leaf": return .clover8
        case "burst": return .burst
        case "softburst": return .softBurst
        case "boom": return .boom
        case "softboom": return .softBoom
        case "flower": return .flower
        case "puffy": return .puffy
        case "puffydiamond": return .puffyDiamond
        case "pixelcircle": return .pixelCircle
        case "pixeltriangle": return .pixelTriangle
        case "bun": return .bun
        case "heart": return .heart
        default: return .circle
        }
    }
}

/// Generates geometric mask paths for Material 3 Expressive shapes and user avatars,
/// plus real-time vertex-interpolated shape morphing across all 35 M3 Expressive shapes.
public enum AvatarShapeGenerator: Sendable {

    /// The 12 classic user avatar shape names, in catalog order.
    public static let allShapeNames: [String] = [
        "circle", "cookie4", "cookie7", "cookie12", "clover4", "clover8",
        "sunny", "pentagon", "arch", "slanted", "gem", "square"
    ]

    /// All 35 Google Material 3 Expressive shape names.
    public static let expressiveShapeNames: [String] = MaterialExpressiveShape.allCases.map(\.rawValue)

    /// Default 7-shape cycle used by the M3 Expressive `LoadingIndicator`.
    public static let loadingIndicatorCycle: [MaterialExpressiveShape] = [
        .softBurst, .cookie9, .pentagon, .pill, .sunny, .cookie4, .oval
    ]

    public static func path(for shapeName: String, in rect: CGRect) -> CGPath {
        path(for: MaterialExpressiveShape.resolve(shapeName), in: rect)
    }

    public static func path(for shape: MaterialExpressiveShape, in rect: CGRect) -> CGPath {
        let w = rect.width
        let h = rect.height
        guard w > 0, h > 0 else {
            return CGPath(rect: rect, transform: nil)
        }

        let cx = rect.midX
        let cy = rect.midY
        let r = min(w, h) / 2.0

        switch shape {
        case .circle:
            return CGPath(ellipseIn: rect, transform: nil)
        case .square:
            return CGPath(roundedRect: rect, cornerWidth: w * 0.22, cornerHeight: h * 0.22, transform: nil)
        case .slanted:
            return slantedPath(rect: rect)
        case .arch:
            return archPath(rect: rect)
        case .fan:
            return fanPath(rect: rect)
        case .arrow:
            return arrowPath(rect: rect)
        case .semiCircle:
            return semiCirclePath(rect: rect)
        case .oval:
            return ovalPath(rect: rect)
        case .pill:
            return pillPath(rect: rect)
        case .triangle:
            return roundedRegularPolygonPath(cx: cx, cy: cy, radius: r * 0.96, sides: 3, startAngle: -.pi / 2.0, cornerFraction: 0.20)
        case .diamond:
            return roundedRegularPolygonPath(cx: cx, cy: cy, radius: r * 0.98, sides: 4, startAngle: -.pi / 2.0, cornerFraction: 0.16)
        case .clamShell:
            return clamShellPath(cx: cx, cy: cy, radius: r)
        case .pentagon:
            return regularPolygonPath(cx: cx, cy: cy, radius: r, sides: 5, startAngle: -.pi / 2.0)
        case .gem:
            return gemPath(rect: rect)
        case .sunny:
            return sunnyPath(cx: cx, cy: cy, outerR: r, innerR: r * 0.78, rays: 8)
        case .verySunny:
            return sunnyPath(cx: cx, cy: cy, outerR: r, innerR: r * 0.68, rays: 12)
        case .cookie4:
            return modulatedPolarPath(cx: cx, cy: cy, baseR: r, frequency: 4, amplitude: 0.14, steps: 96)
        case .cookie6:
            return modulatedPolarPath(cx: cx, cy: cy, baseR: r, frequency: 6, amplitude: 0.13, steps: 108)
        case .cookie7:
            return modulatedPolarPath(cx: cx, cy: cy, baseR: r, frequency: 7, amplitude: 0.12, steps: 112)
        case .cookie9:
            return modulatedPolarPath(cx: cx, cy: cy, baseR: r, frequency: 9, amplitude: 0.11, steps: 126)
        case .cookie12:
            return modulatedPolarPath(cx: cx, cy: cy, baseR: r, frequency: 12, amplitude: 0.10, steps: 144)
        case .ghostish:
            return ghostishPath(rect: rect)
        case .clover4:
            return cloverPath(cx: cx, cy: cy, baseR: r, leaves: 4, steps: 96)
        case .clover8:
            return cloverPath(cx: cx, cy: cy, baseR: r, leaves: 8, steps: 128)
        case .burst:
            return sunnyPath(cx: cx, cy: cy, outerR: r, innerR: r * 0.62, rays: 10)
        case .softBurst:
            return modulatedPolarPath(cx: cx, cy: cy, baseR: r, frequency: 10, amplitude: 0.15, steps: 140)
        case .boom:
            return sunnyPath(cx: cx, cy: cy, outerR: r, innerR: r * 0.56, rays: 14)
        case .softBoom:
            return modulatedPolarPath(cx: cx, cy: cy, baseR: r, frequency: 14, amplitude: 0.12, steps: 156)
        case .flower:
            return flowerPath(cx: cx, cy: cy, baseR: r, petals: 6, steps: 120)
        case .puffy:
            return puffyPath(cx: cx, cy: cy, baseR: r, lobes: 4, steps: 112)
        case .puffyDiamond:
            return puffyDiamondPath(cx: cx, cy: cy, baseR: r, steps: 112)
        case .pixelCircle:
            return pixelCirclePath(rect: rect)
        case .pixelTriangle:
            return pixelTrianglePath(rect: rect)
        case .bun:
            return bunPath(rect: rect)
        case .heart:
            return heartPath(rect: rect)
        }
    }

    // MARK: - M3 Expressive Shape Morphing

    /// Computes a smoothly morphed `CGPath` between `from` (`progress = 0`) and `to` (`progress = 1`)
    /// by interpolating uniform polar contour samples in `rect`.
    public static func morphedPath(
        from: MaterialExpressiveShape,
        to: MaterialExpressiveShape,
        progress: CGFloat,
        in rect: CGRect,
        steps: Int = 128
    ) -> CGPath {
        guard rect.width > 0, rect.height > 0 else {
            return CGPath(rect: rect, transform: nil)
        }
        let t = min(1.0, max(0.0, progress))
        if t <= 0.0001 {
            return path(for: from, in: rect)
        }
        if t >= 0.9999 {
            return path(for: to, in: rect)
        }

        let n = max(32, steps)
        let ringA = contourPoints(for: from, in: rect, count: n)
        let ringB = contourPoints(for: to, in: rect, count: n)

        let path = CGMutablePath()
        for i in 0..<n {
            let a = ringA[i]
            let b = ringB[i]
            let pt = CGPoint(
                x: a.x + (b.x - a.x) * t,
                y: a.y + (b.y - a.y) * t
            )
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }

    /// Computes a continuously morphed `CGPath` across a loop of shapes for a phase in `0..<Double(shapes.count)`.
    public static func morphedPath(
        shapes: [MaterialExpressiveShape],
        phase: CGFloat,
        in rect: CGRect,
        steps: Int = 128
    ) -> CGPath {
        guard !shapes.isEmpty else {
            return path(for: .circle, in: rect)
        }
        if shapes.count == 1 {
            return path(for: shapes[0], in: rect)
        }
        let count = CGFloat(shapes.count)
        var wrapped = phase.truncatingRemainder(dividingBy: count)
        if wrapped < 0 { wrapped += count }
        let idx = Int(floor(wrapped)) % shapes.count
        let nextIdx = (idx + 1) % shapes.count
        let localProgress = wrapped - floor(wrapped)
        return morphedPath(from: shapes[idx], to: shapes[nextIdx], progress: localProgress, in: rect, steps: steps)
    }

    /// Samples `count` points around the perimeter of `shape` in `rect` parameterized by angle `theta` in `0..<2π`.
    public static func contourPoints(
        for shape: MaterialExpressiveShape,
        in rect: CGRect,
        count: Int = 128
    ) -> [CGPoint] {
        let cx = rect.midX
        let cy = rect.midY
        let rx = rect.width / 2.0
        let ry = rect.height / 2.0
        let n = max(16, count)
        let dTheta = (2.0 * CGFloat.pi) / CGFloat(n)

        return (0..<n).map { i in
            let theta = CGFloat(i) * dTheta - .pi / 2.0
            let norm = normalizedPolarPoint(for: shape, theta: theta)
            return CGPoint(x: cx + norm.x * rx, y: cy + norm.y * ry)
        }
    }

    private static func normalizedPolarPoint(for shape: MaterialExpressiveShape, theta: CGFloat) -> CGPoint {
        let r: CGFloat
        switch shape {
        case .circle:
            r = 1.0
        case .square:
            // Superellipse squircle approximation
            let c = abs(cos(theta))
            let s = abs(sin(theta))
            r = 1.0 / pow(pow(c, 4.5) + pow(s, 4.5), 1.0 / 4.5)
        case .slanted:
            let base = 0.88 + 0.10 * sin(2.0 * theta + 0.5)
            r = base
        case .arch:
            r = theta < 0 ? 1.0 : min(1.0, 0.92 / max(0.55, max(abs(cos(theta)), abs(sin(theta)))))
        case .fan:
            r = 0.84 + 0.16 * cos(theta - .pi / 4.0)
        case .arrow:
            r = 0.78 + 0.22 * cos(theta + .pi / 4.0)
        case .semiCircle:
            r = sin(theta) <= 0.15 ? 0.95 : 0.62
        case .oval:
            return CGPoint(x: 0.78 * cos(theta), y: 1.0 * sin(theta))
        case .pill:
            return CGPoint(x: 0.68 * cos(theta), y: 0.98 * sin(theta))
        case .triangle, .pixelTriangle:
            r = polygonPolarRadius(sides: 3, theta: theta + .pi / 2.0, roundness: 0.25)
        case .diamond:
            r = polygonPolarRadius(sides: 4, theta: theta + .pi / 2.0, roundness: 0.20)
        case .clamShell:
            r = 0.84 + 0.14 * cos(5.0 * theta) * (sin(theta) < 0 ? 1.0 : 0.35)
        case .pentagon:
            r = polygonPolarRadius(sides: 5, theta: theta + .pi / 2.0, roundness: 0.12)
        case .gem:
            r = polygonPolarRadius(sides: 8, theta: theta + .pi / 8.0, roundness: 0.10)
        case .sunny:
            r = 0.89 + 0.11 * cos(8.0 * theta)
        case .verySunny:
            r = 0.84 + 0.16 * cos(12.0 * theta)
        case .cookie4:
            r = 0.86 + 0.14 * cos(4.0 * theta)
        case .cookie6:
            r = 0.87 + 0.13 * cos(6.0 * theta)
        case .cookie7:
            r = 0.88 + 0.12 * cos(7.0 * theta)
        case .cookie9:
            r = 0.89 + 0.11 * cos(9.0 * theta)
        case .cookie12:
            r = 0.90 + 0.10 * cos(12.0 * theta)
        case .ghostish:
            r = sin(theta) > 0.2 ? (0.88 + 0.10 * cos(6.0 * theta)) : 0.95
        case .clover4:
            r = 0.72 + 0.28 * abs(cos(2.0 * theta))
        case .clover8:
            r = 0.72 + 0.28 * abs(cos(4.0 * theta))
        case .burst:
            r = 0.81 + 0.19 * cos(10.0 * theta)
        case .softBurst:
            r = 0.85 + 0.15 * cos(10.0 * theta)
        case .boom:
            r = 0.78 + 0.22 * cos(14.0 * theta)
        case .softBoom:
            r = 0.88 + 0.12 * cos(14.0 * theta)
        case .flower:
            r = 0.76 + 0.24 * abs(cos(3.0 * theta))
        case .puffy:
            r = 0.82 + 0.18 * pow(abs(cos(2.0 * theta)), 0.6)
        case .puffyDiamond:
            r = 0.80 + 0.20 * abs(cos(2.0 * (theta + .pi / 4.0)))
        case .pixelCircle:
            let qTheta = round(theta / (.pi / 8.0)) * (.pi / 8.0)
            return CGPoint(x: 0.94 * cos(qTheta), y: 0.94 * sin(qTheta))
        case .bun:
            return CGPoint(x: 0.98 * cos(theta), y: (0.76 + 0.12 * cos(2.0 * theta)) * sin(theta))
        case .heart:
            let t = theta + .pi / 2.0
            let hx = 16.0 * pow(sin(t), 3.0) / 17.0
            let hy = -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)) / 17.0
            return CGPoint(x: hx, y: hy)
        }
        return CGPoint(x: r * cos(theta), y: r * sin(theta))
    }

    private static func polygonPolarRadius(sides: Int, theta: CGFloat, roundness: CGFloat) -> CGFloat {
        let n = CGFloat(max(3, sides))
        let sector = (2.0 * .pi) / n
        var local = theta.truncatingRemainder(dividingBy: sector)
        if local < 0 { local += sector }
        let centered = local - sector / 2.0
        let raw = cos(sector / 2.0) / max(0.2, cos(centered))
        return raw * (1.0 - roundness) + roundness
    }

    // MARK: - Private Path Solvers

    private static func modulatedPolarPath(
        cx: CGFloat,
        cy: CGFloat,
        baseR: CGFloat,
        frequency: Int,
        amplitude: CGFloat,
        steps: Int
    ) -> CGPath {
        let path = CGMutablePath()
        let freq = CGFloat(frequency)
        let totalSteps = max(24, steps)
        let dTheta = (2.0 * CGFloat.pi) / CGFloat(totalSteps)

        for i in 0..<totalSteps {
            let theta = CGFloat(i) * dTheta
            let radius = baseR * (1.0 - amplitude + amplitude * cos(freq * theta))
            let x = cx + radius * cos(theta)
            let y = cy + radius * sin(theta)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }

    private static func cloverPath(
        cx: CGFloat,
        cy: CGFloat,
        baseR: CGFloat,
        leaves: Int,
        steps: Int
    ) -> CGPath {
        let path = CGMutablePath()
        let halfLeaves = CGFloat(leaves) / 2.0
        let totalSteps = max(24, steps)
        let dTheta = (2.0 * CGFloat.pi) / CGFloat(totalSteps)

        for i in 0..<totalSteps {
            let theta = CGFloat(i) * dTheta
            let modulation = abs(cos(halfLeaves * theta))
            let radius = baseR * (0.72 + 0.28 * modulation)
            let x = cx + radius * cos(theta)
            let y = cy + radius * sin(theta)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }

    private static func flowerPath(
        cx: CGFloat,
        cy: CGFloat,
        baseR: CGFloat,
        petals: Int,
        steps: Int
    ) -> CGPath {
        let path = CGMutablePath()
        let halfPetals = CGFloat(petals) / 2.0
        let totalSteps = max(36, steps)
        let dTheta = (2.0 * CGFloat.pi) / CGFloat(totalSteps)

        for i in 0..<totalSteps {
            let theta = CGFloat(i) * dTheta
            let modulation = pow(abs(cos(halfPetals * theta)), 0.75)
            let radius = baseR * (0.68 + 0.32 * modulation)
            let x = cx + radius * cos(theta)
            let y = cy + radius * sin(theta)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }

    private static func puffyPath(
        cx: CGFloat,
        cy: CGFloat,
        baseR: CGFloat,
        lobes: Int,
        steps: Int
    ) -> CGPath {
        let path = CGMutablePath()
        let f = CGFloat(lobes)
        let totalSteps = max(36, steps)
        let dTheta = (2.0 * CGFloat.pi) / CGFloat(totalSteps)

        for i in 0..<totalSteps {
            let theta = CGFloat(i) * dTheta
            let radius = baseR * (0.84 + 0.16 * abs(sin(f * theta / 2.0)))
            let x = cx + radius * cos(theta)
            let y = cy + radius * sin(theta)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }

    private static func puffyDiamondPath(
        cx: CGFloat,
        cy: CGFloat,
        baseR: CGFloat,
        steps: Int
    ) -> CGPath {
        let path = CGMutablePath()
        let totalSteps = max(36, steps)
        let dTheta = (2.0 * CGFloat.pi) / CGFloat(totalSteps)

        for i in 0..<totalSteps {
            let theta = CGFloat(i) * dTheta
            let radius = baseR * (0.78 + 0.22 * pow(abs(cos(2.0 * theta)), 0.7))
            let x = cx + radius * cos(theta)
            let y = cy + radius * sin(theta)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }

    private static func sunnyPath(
        cx: CGFloat,
        cy: CGFloat,
        outerR: CGFloat,
        innerR: CGFloat,
        rays: Int
    ) -> CGPath {
        let path = CGMutablePath()
        let totalPoints = rays * 2
        let dTheta = (2.0 * CGFloat.pi) / CGFloat(totalPoints)

        for i in 0..<totalPoints {
            let theta = CGFloat(i) * dTheta - CGFloat.pi / 2.0
            let radius = (i % 2 == 0) ? outerR : innerR
            let x = cx + radius * cos(theta)
            let y = cy + radius * sin(theta)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }

    private static func regularPolygonPath(
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        sides: Int,
        startAngle: CGFloat
    ) -> CGPath {
        let path = CGMutablePath()
        let dTheta = (2.0 * CGFloat.pi) / CGFloat(sides)

        for i in 0..<sides {
            let theta = startAngle + CGFloat(i) * dTheta
            let x = cx + radius * cos(theta)
            let y = cy + radius * sin(theta)

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }

    private static func roundedRegularPolygonPath(
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        sides: Int,
        startAngle: CGFloat,
        cornerFraction: CGFloat
    ) -> CGPath {
        let path = CGMutablePath()
        let n = max(3, sides)
        let dTheta = (2.0 * CGFloat.pi) / CGFloat(n)
        let vertices: [CGPoint] = (0..<n).map { i in
            let theta = startAngle + CGFloat(i) * dTheta
            return CGPoint(x: cx + radius * cos(theta), y: cy + radius * sin(theta))
        }
        let cr = radius * cornerFraction
        let mid0 = CGPoint(x: (vertices[0].x + vertices[1].x) * 0.5, y: (vertices[0].y + vertices[1].y) * 0.5)
        path.move(to: mid0)
        for i in 0..<n {
            let current = vertices[(i + 1) % n]
            let next = vertices[(i + 2) % n]
            path.addArc(tangent1End: current, tangent2End: next, radius: cr)
        }
        path.closeSubpath()
        return path
    }

    private static func archPath(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let r = rect.width / 2.0
        let bottom = rect.maxY
        let left = rect.minX
        let right = rect.maxX
        let domeCenterY = rect.minY + r

        path.move(to: CGPoint(x: left, y: bottom))
        path.addLine(to: CGPoint(x: right, y: bottom))
        path.addLine(to: CGPoint(x: right, y: domeCenterY))
        path.addArc(
            center: CGPoint(x: rect.midX, y: domeCenterY),
            radius: r,
            startAngle: 0,
            endAngle: CGFloat.pi,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: left, y: bottom))
        path.closeSubpath()
        return path
    }

    private static func fanPath(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let w = rect.width
        let h = rect.height
        let cr = min(w, h) * 0.16
        let p0 = CGPoint(x: rect.minX, y: rect.maxY)
        let p1 = CGPoint(x: rect.maxX, y: rect.maxY)
        let p2 = CGPoint(x: rect.maxX, y: rect.minY + h * 0.25)
        let p3 = CGPoint(x: rect.minX + w * 0.25, y: rect.minY)

        path.move(to: CGPoint(x: (p0.x + p1.x) * 0.5, y: p0.y))
        path.addArc(tangent1End: p1, tangent2End: p2, radius: cr)
        path.addQuadCurve(to: p3, control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addArc(tangent1End: p0, tangent2End: p1, radius: cr)
        path.closeSubpath()
        return path
    }

    private static func arrowPath(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let w = rect.width
        let h = rect.height
        let cx = rect.midX
        let pTop = CGPoint(x: cx, y: rect.minY + h * 0.04)
        let pRight = CGPoint(x: rect.maxX - w * 0.06, y: rect.minY + h * 0.56)
        let pNotchRight = CGPoint(x: cx + w * 0.18, y: rect.minY + h * 0.56)
        let pBottomRight = CGPoint(x: cx + w * 0.18, y: rect.maxY - h * 0.06)
        let pBottomLeft = CGPoint(x: cx - w * 0.18, y: rect.maxY - h * 0.06)
        let pNotchLeft = CGPoint(x: cx - w * 0.18, y: rect.minY + h * 0.56)
        let pLeft = CGPoint(x: rect.minX + w * 0.06, y: rect.minY + h * 0.56)

        path.move(to: pTop)
        path.addLine(to: pRight)
        path.addLine(to: pNotchRight)
        path.addLine(to: pBottomRight)
        path.addLine(to: pBottomLeft)
        path.addLine(to: pNotchLeft)
        path.addLine(to: pLeft)
        path.closeSubpath()
        return path
    }

    private static func semiCirclePath(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let r = min(rect.width, rect.height) * 0.48
        let cy = rect.minY + rect.height * 0.65
        path.move(to: CGPoint(x: rect.midX - r, y: cy))
        path.addArc(center: CGPoint(x: rect.midX, y: cy), radius: r, startAngle: .pi, endAngle: 0, clockwise: false)
        path.closeSubpath()
        return path
    }

    private static func ovalPath(rect: CGRect) -> CGPath {
        let insetX = rect.width * 0.12
        let ovalRect = rect.insetBy(dx: insetX, dy: rect.height * 0.02)
        return CGPath(ellipseIn: ovalRect, transform: nil)
    }

    private static func pillPath(rect: CGRect) -> CGPath {
        let insetX = rect.width * 0.16
        let pillRect = rect.insetBy(dx: insetX, dy: rect.height * 0.02)
        let cr = min(pillRect.width, pillRect.height) * 0.5
        return CGPath(roundedRect: pillRect, cornerWidth: cr, cornerHeight: cr, transform: nil)
    }

    private static func clamShellPath(cx: CGFloat, cy: CGFloat, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let steps = 96
        for i in 0..<steps {
            let theta = (CGFloat(i) / CGFloat(steps)) * 2.0 * .pi
            let scallop = sin(theta) < 0 ? (0.12 * cos(5.0 * theta)) : 0.03 * cos(3.0 * theta)
            let r = radius * (0.86 + scallop)
            let pt = CGPoint(x: cx + r * cos(theta), y: cy + r * sin(theta))
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }

    private static func ghostishPath(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let w = rect.width
        let h = rect.height
        let r = w * 0.46
        let left = rect.midX - r
        let right = rect.midX + r
        let domeY = rect.minY + r + h * 0.04
        let bottomY = rect.maxY - h * 0.06

        path.move(to: CGPoint(x: left, y: bottomY))
        path.addLine(to: CGPoint(x: left, y: domeY))
        path.addArc(center: CGPoint(x: rect.midX, y: domeY), radius: r, startAngle: .pi, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: right, y: bottomY))

        // Wavy bottom skirt (3 scallops)
        let scallops = 3
        let stepW = (right - left) / CGFloat(scallops)
        for i in 0..<scallops {
            let startX = right - CGFloat(i) * stepW
            let endX = startX - stepW
            let midX = (startX + endX) * 0.5
            let crestY = (i % 2 == 0) ? (bottomY - h * 0.10) : (bottomY + h * 0.04)
            path.addQuadCurve(to: CGPoint(x: endX, y: bottomY), control: CGPoint(x: midX, y: crestY))
        }
        path.closeSubpath()
        return path
    }

    private static func pixelCirclePath(rect: CGRect) -> CGPath {
        // Stepped 8-bit pixel circle outline
        let path = CGMutablePath()
        let u = min(rect.width, rect.height) / 10.0
        let ox = rect.midX - 5.0 * u
        let oy = rect.midY - 5.0 * u
        let coords: [(CGFloat, CGFloat)] = [
            (3, 0), (7, 0), (7, 1), (9, 1), (9, 3), (10, 3),
            (10, 7), (9, 7), (9, 9), (7, 9), (7, 10), (3, 10),
            (3, 9), (1, 9), (1, 7), (0, 7), (0, 3), (1, 3),
            (1, 1), (3, 1)
        ]
        for (i, (gx, gy)) in coords.enumerated() {
            let pt = CGPoint(x: ox + gx * u, y: oy + gy * u)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }

    private static func pixelTrianglePath(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let u = min(rect.width, rect.height) / 10.0
        let ox = rect.midX - 5.0 * u
        let oy = rect.midY - 5.0 * u
        let coords: [(CGFloat, CGFloat)] = [
            (4, 0), (6, 0), (6, 2), (7, 2), (7, 4), (8, 4),
            (8, 6), (9, 6), (9, 8), (10, 8), (10, 10), (0, 10),
            (0, 8), (1, 8), (1, 6), (2, 6), (2, 4), (3, 4),
            (3, 2), (4, 2)
        ]
        for (i, (gx, gy)) in coords.enumerated() {
            let pt = CGPoint(x: ox + gx * u, y: oy + gy * u)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }

    private static func bunPath(rect: CGRect) -> CGPath {
        let insetY = rect.height * 0.14
        let bunRect = rect.insetBy(dx: rect.width * 0.02, dy: insetY)
        let cr = min(bunRect.width, bunRect.height) * 0.48
        return CGPath(roundedRect: bunRect, cornerWidth: cr, cornerHeight: cr, transform: nil)
    }

    private static func heartPath(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let cx = rect.midX
        let cy = rect.midY + rect.height * 0.04
        let scaleX = rect.width * 0.46
        let scaleY = rect.height * 0.44
        let steps = 96

        for i in 0..<steps {
            let t = (CGFloat(i) / CGFloat(steps)) * 2.0 * .pi
            let hx = pow(sin(t), 3.0)
            let hy = -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)) / 16.0
            let pt = CGPoint(x: cx + hx * scaleX, y: cy + hy * scaleY)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }

    private static func slantedPath(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let shear = rect.width * 0.18
        let cr = min(rect.width, rect.height) * 0.18

        let p1 = CGPoint(x: rect.minX + shear, y: rect.minY)
        let p2 = CGPoint(x: rect.maxX, y: rect.minY)
        let p3 = CGPoint(x: rect.maxX - shear, y: rect.maxY)
        let p4 = CGPoint(x: rect.minX, y: rect.maxY)

        path.move(to: CGPoint(x: p1.x + cr, y: p1.y))
        path.addArc(tangent1End: p2, tangent2End: p3, radius: cr)
        path.addArc(tangent1End: p3, tangent2End: p4, radius: cr)
        path.addArc(tangent1End: p4, tangent2End: p1, radius: cr)
        path.addArc(tangent1End: p1, tangent2End: p2, radius: cr)
        path.closeSubpath()
        return path
    }

    private static func gemPath(rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let w = rect.width
        let h = rect.height

        let insetX = w * 0.25
        let insetY = h * 0.25

        let pt0 = CGPoint(x: rect.minX + insetX, y: rect.minY)
        let pt1 = CGPoint(x: rect.maxX - insetX, y: rect.minY)
        let pt2 = CGPoint(x: rect.maxX, y: rect.minY + insetY)
        let pt3 = CGPoint(x: rect.maxX, y: rect.maxY - insetY)
        let pt4 = CGPoint(x: rect.maxX - insetX, y: rect.maxY)
        let pt5 = CGPoint(x: rect.minX + insetX, y: rect.maxY)
        let pt6 = CGPoint(x: rect.minX, y: rect.maxY - insetY)
        let pt7 = CGPoint(x: rect.minX, y: rect.minY + insetY)

        path.move(to: pt0)
        path.addLine(to: pt1)
        path.addLine(to: pt2)
        path.addLine(to: pt3)
        path.addLine(to: pt4)
        path.addLine(to: pt5)
        path.addLine(to: pt6)
        path.addLine(to: pt7)
        path.closeSubpath()
        return path
    }
}
