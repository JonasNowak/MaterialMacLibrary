import SwiftUI
import CoreGraphics

/// Role of a segment inside a segmented pill run (solo / first / middle / last).
public enum MaterialSegmentRole: String, Sendable, Codable, Equatable, CaseIterable {
    case solo
    case first
    case middle
    case last
}

/// A custom Shape that renders rounded corners according to a segment's role and axis
/// orientation. Exact corner curve logic from DMS `M3SegmentedPillShape`:
/// outer ends get the full half-extent radius, inner joints get `min(radius, 4)`.
public struct SegmentedPillShape: Shape {
    public var role: MaterialSegmentRole
    public var isVertical: Bool
    public var radius: CGFloat

    public init(role: MaterialSegmentRole, isVertical: Bool = false, radius: CGFloat = 14) {
        self.role = role
        self.isVertical = isVertical
        self.radius = radius
    }

    public func path(in rect: CGRect) -> Path {
        let maxR = min(rect.width, rect.height) / 2.0
        let innerR = min(radius, 4.0)

        let topLeading: CGFloat
        let bottomLeading: CGFloat
        let bottomTrailing: CGFloat
        let topTrailing: CGFloat

        switch role {
        case .solo:
            topLeading = maxR
            topTrailing = maxR
            bottomLeading = maxR
            bottomTrailing = maxR

        case .middle:
            topLeading = innerR
            topTrailing = innerR
            bottomLeading = innerR
            bottomTrailing = innerR

        case .first:
            if isVertical {
                // Top rounded, bottom flat/inner
                topLeading = maxR
                topTrailing = maxR
                bottomLeading = innerR
                bottomTrailing = innerR
            } else {
                // Left rounded, right flat/inner
                topLeading = maxR
                bottomLeading = maxR
                topTrailing = innerR
                bottomTrailing = innerR
            }

        case .last:
            if isVertical {
                // Top flat/inner, bottom rounded
                topLeading = innerR
                topTrailing = innerR
                bottomLeading = maxR
                bottomTrailing = maxR
            } else {
                // Left flat/inner, right rounded
                topLeading = innerR
                bottomLeading = innerR
                topTrailing = maxR
                bottomTrailing = maxR
            }
        }

        return UnevenRoundedRectangle(
            topLeadingRadius: topLeading,
            bottomLeadingRadius: bottomLeading,
            bottomTrailingRadius: bottomTrailing,
            topTrailingRadius: topTrailing
        ).path(in: rect)
    }
}
