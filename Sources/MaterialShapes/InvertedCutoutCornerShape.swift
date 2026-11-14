import SwiftUI
import CoreGraphics

/// Draws an island or panel container with optional concave top-left/top-right fillets
/// ("inverted cutout" goth corners) that blend seamlessly into the top screen edge or
/// Mac hardware notch. Generalized from DMS `GothCornerShape` (DIslandView).
public struct InvertedCutoutCornerShape: Shape {
    public var topLeadingRadius: CGFloat
    public var topTrailingRadius: CGFloat
    public var bottomTrailingRadius: CGFloat
    public var bottomLeadingRadius: CGFloat
    public var concaveTopFillets: Bool
    public var filletRadius: CGFloat

    public init(
        topLeadingRadius: CGFloat = 18,
        topTrailingRadius: CGFloat = 18,
        bottomTrailingRadius: CGFloat = 18,
        bottomLeadingRadius: CGFloat = 18,
        concaveTopFillets: Bool = false,
        filletRadius: CGFloat = 12
    ) {
        self.topLeadingRadius = topLeadingRadius
        self.topTrailingRadius = topTrailingRadius
        self.bottomTrailingRadius = bottomTrailingRadius
        self.bottomLeadingRadius = bottomLeadingRadius
        self.concaveTopFillets = concaveTopFillets
        self.filletRadius = filletRadius
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        guard rect.width > 0 && rect.height > 0 else { return path }

        if concaveTopFillets {
            let f = min(filletRadius, rect.width * 0.25, rect.height * 0.5)
            let br = min(bottomTrailingRadius, (rect.width - 2 * f) * 0.5, rect.height * 0.5)
            let bl = min(bottomLeadingRadius, (rect.width - 2 * f) * 0.5, rect.height * 0.5)

            // Start at top-left outer flange
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            // Top edge across to top-right outer flange
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            // Concave circular fillet curving inward-downward on right
            path.addArc(
                center: CGPoint(x: rect.maxX, y: rect.minY + f),
                radius: f,
                startAngle: .degrees(270),
                endAngle: .degrees(180),
                clockwise: true
            )
            // Right vertical edge down to bottom-right corner
            path.addLine(to: CGPoint(x: rect.maxX - f, y: rect.maxY - br))
            path.addArc(
                center: CGPoint(x: rect.maxX - f - br, y: rect.maxY - br),
                radius: br,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
            // Bottom edge across to bottom-left corner
            path.addLine(to: CGPoint(x: rect.minX + f + bl, y: rect.maxY))
            path.addArc(
                center: CGPoint(x: rect.minX + f + bl, y: rect.maxY - bl),
                radius: bl,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
            // Left vertical edge up to top-left concave fillet
            path.addLine(to: CGPoint(x: rect.minX + f, y: rect.minY + f))
            path.addArc(
                center: CGPoint(x: rect.minX, y: rect.minY + f),
                radius: f,
                startAngle: .degrees(0),
                endAngle: .degrees(270),
                clockwise: true
            )
            path.closeSubpath()
            return path
        } else {
            let tl = min(topLeadingRadius, rect.width * 0.5, rect.height * 0.5)
            let tr = min(topTrailingRadius, rect.width * 0.5, rect.height * 0.5)
            let br = min(bottomTrailingRadius, rect.width * 0.5, rect.height * 0.5)
            let bl = min(bottomLeadingRadius, rect.width * 0.5, rect.height * 0.5)

            path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
            path.addArc(
                center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                radius: tr,
                startAngle: .degrees(-90),
                endAngle: .degrees(0),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
            path.addArc(
                center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                radius: br,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
            path.addArc(
                center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                radius: bl,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
            path.addArc(
                center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                radius: tl,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
            path.closeSubpath()
            return path
        }
    }
}
