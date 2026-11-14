import SwiftUI
import MaterialTokens
import MaterialShapes

/// Clips content to a `SegmentedPillShape` matching the segment's role and axis, scales the
/// radius through the theme's shape tokens, and draws the thin inner divider between
/// adjacent segments. All colors come from `@Environment(\.materialTheme)`.
/// Generalized from DMS `M3SegmentedPillModifier`.
public struct SegmentedPillModifier: ViewModifier {
    public var role: MaterialSegmentRole
    public var isVertical: Bool
    public var radius: CGFloat

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(role: MaterialSegmentRole, isVertical: Bool = false, radius: CGFloat = 14) {
        self.role = role
        self.isVertical = isVertical
        self.radius = radius
    }

    public func body(content: Content) -> some View {
        let effectiveRadius = theme.cornerRadius(base: radius)
        let shape = SegmentedPillShape(role: role, isVertical: isVertical, radius: effectiveRadius)
        content
            .clipShape(shape)
            .overlay(alignment: isVertical ? .bottom : .trailing) {
                if role == .first || role == .middle {
                    Rectangle()
                        .fill(theme.outlineVariant.opacity(0.28))
                        .frame(
                            width: isVertical ? 16 : 1,
                            height: isVertical ? 1 : 16
                        )
                }
            }
    }
}

public extension View {
    /// Applies the Material 3 segmented-pill shape for the given segment role.
    func m3SegmentedPill(role: MaterialSegmentRole, isVertical: Bool = false, radius: CGFloat = 14) -> some View {
        modifier(SegmentedPillModifier(role: role, isVertical: isVertical, radius: radius))
    }
}
