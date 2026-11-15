import SwiftUI
import AppKit
import MaterialTokens
import MaterialShapes

// MARK: - Popout Layout Helper (SURF-001 Connected Mode Positioning)

/// Pure, value-type description of everything `PopoutLayoutHelper` needs to position a
/// popout. Decoupled from DMS window controllers: callers pass the bar frame, screen
/// frames, and mouse location explicitly.
public struct PopoutLayoutInput: Sendable, Equatable {
    public var bodyWidth: CGFloat
    public var bodyHeight: CGFloat
    public var anchorX: CGFloat?
    /// Bar edge: "top", "bottom", "left", or "right".
    public var barPosition: String
    /// Connected ("gothic corners") mode: popout attaches flush to the bar (gap = 0).
    public var connected: Bool
    public var filletRadius: CGFloat
    /// Frame of the bar panel on screen; pass `.zero` when unknown (fallbacks apply).
    public var barFrame: CGRect
    /// Screen visible frame (menu-bar excluded).
    public var visibleFrame: CGRect
    /// Screen full frame.
    public var fullFrame: CGRect
    public var mouseLocation: CGPoint
    public var marginX: CGFloat
    public var isControlCenter: Bool
    public var anchorToControlCenter: Bool
    /// Frame of the control center panel when `anchorToControlCenter` is true.
    public var controlCenterFrame: CGRect
    /// Fallback bar height used when `barFrame` is empty (horizontal bars).
    public var barHeight: CGFloat
    /// Fallback bar width used when `barFrame` is empty (vertical bars).
    public var verticalBarWidth: CGFloat

    public init(
        bodyWidth: CGFloat,
        bodyHeight: CGFloat,
        anchorX: CGFloat? = nil,
        barPosition: String = "top",
        connected: Bool = false,
        filletRadius: CGFloat = 14,
        barFrame: CGRect = .zero,
        visibleFrame: CGRect,
        fullFrame: CGRect,
        mouseLocation: CGPoint = .zero,
        marginX: CGFloat = 8,
        isControlCenter: Bool = false,
        anchorToControlCenter: Bool = false,
        controlCenterFrame: CGRect = .zero,
        barHeight: CGFloat = 42,
        verticalBarWidth: CGFloat = 56
    ) {
        self.bodyWidth = bodyWidth
        self.bodyHeight = bodyHeight
        self.anchorX = anchorX
        self.barPosition = barPosition.lowercased()
        self.connected = connected
        self.filletRadius = filletRadius
        self.barFrame = barFrame
        self.visibleFrame = visibleFrame
        self.fullFrame = fullFrame
        self.mouseLocation = mouseLocation
        self.marginX = marginX
        self.isControlCenter = isControlCenter
        self.anchorToControlCenter = anchorToControlCenter
        self.controlCenterFrame = controlCenterFrame
        self.barHeight = barHeight
        self.verticalBarWidth = verticalBarWidth
    }

    public var isBottom: Bool { barPosition == "bottom" }
    public var isVertical: Bool { barPosition == "left" || barPosition == "right" }
}

/// Calculates pixel-perfect positioning and bounding frames for popouts according to
/// DMS specification `SURF-001`. In connected mode the popout attaches flush to the bar
/// (`gap = 0`) and expands its dimensions to accommodate concave fillet flanges.
/// Generalized from DMS `PopoutLayoutHelper` with explicit, store-free inputs.
public enum PopoutLayoutHelper {
    /// Separation between popout and bar: flush (0) in connected mode, otherwise 8pt.
    public static func gap(connected: Bool) -> CGFloat {
        connected ? 0.0 : 8.0
    }

    /// Total popout size including fillet flanges in connected mode.
    public static func totalSize(for input: PopoutLayoutInput) -> CGSize {
        let filletR: CGFloat = input.connected ? input.filletRadius : 0.0
        let w: CGFloat = (input.connected && !input.isVertical) ? (input.bodyWidth + 2 * filletR) : input.bodyWidth
        let h: CGFloat = (input.connected && input.isVertical) ? (input.bodyHeight + 2 * filletR) : input.bodyHeight
        return CGSize(width: w, height: h)
    }

    /// Computes the popout's screen frame for the given input.
    public static func frame(for input: PopoutLayoutInput) -> CGRect {
        let total = totalSize(for: input)
        let totalWidth = total.width
        let totalHeight = total.height
        let gap = gap(connected: input.connected)
        let filletR: CGFloat = input.connected ? input.filletRadius : 0.0

        let visibleFrame = input.visibleFrame
        let fullFrame = input.fullFrame
        let barFrame = input.barFrame

        var xPos: CGFloat
        var yPos: CGFloat

        if input.anchorToControlCenter {
            let ccFrame = input.controlCenterFrame
            xPos = ccFrame.width > 0 ? ccFrame.minX : (fullFrame.maxX - totalWidth - 12)
            if input.isBottom {
                yPos = min(visibleFrame.maxY - totalHeight - gap, ccFrame.maxY + gap)
            } else if !input.isVertical {
                yPos = ccFrame.height > 0 ? (ccFrame.maxY - totalHeight) : max(visibleFrame.minY + gap, ccFrame.minY)
            } else {
                yPos = max(visibleFrame.minY + 12, min(visibleFrame.maxY - totalHeight - 12, ccFrame.midY - totalHeight / 2.0))
            }
            return CGRect(x: xPos, y: yPos, width: totalWidth, height: totalHeight)
        }

        if input.isControlCenter {
            xPos = fullFrame.maxX - totalWidth - input.marginX
            xPos = max(visibleFrame.minX + 8, min(visibleFrame.maxX - totalWidth - 8, xPos))

            if input.isBottom {
                let barTop = barFrame.height > 0 ? barFrame.maxY : (fullFrame.minY + 8 + input.barHeight)
                yPos = input.connected ? barTop : min(visibleFrame.maxY - totalHeight - gap, barTop + gap)
            } else if !input.isVertical {
                let barBottom = barFrame.height > 0 ? barFrame.minY : (fullFrame.maxY - 8 - input.barHeight)
                yPos = input.connected ? (barBottom - totalHeight) : max(visibleFrame.minY + gap, barBottom - totalHeight - gap)
            } else {
                let targetY = input.mouseLocation.y
                yPos = max(visibleFrame.minY + 12, min(visibleFrame.maxY - totalHeight - 12, targetY - totalHeight / 2.0))
                if input.barPosition == "left" {
                    let barRight = barFrame.width > 0 ? barFrame.maxX : (fullFrame.minX + input.verticalBarWidth + 8)
                    xPos = barRight + gap
                } else {
                    let barLeft = barFrame.width > 0 ? barFrame.minX : (fullFrame.maxX - input.verticalBarWidth - 8)
                    xPos = barLeft - totalWidth - gap
                }
            }
            return CGRect(x: xPos, y: yPos, width: totalWidth, height: totalHeight)
        }

        if input.isVertical {
            let targetY = input.mouseLocation.y
            yPos = targetY - totalHeight / 2.0 - (input.connected ? filletR : 0.0)
            yPos = max(visibleFrame.minY + 12, min(visibleFrame.maxY - totalHeight - 12, yPos))
            let barRight = barFrame.width > 0 ? barFrame.maxX : (fullFrame.minX + input.verticalBarWidth + 8)
            let barLeft = barFrame.width > 0 ? barFrame.minX : (fullFrame.maxX - input.verticalBarWidth - 8)
            if input.barPosition == "left" {
                xPos = barRight + gap
            } else {
                xPos = barLeft - totalWidth - gap
            }
        } else if input.isBottom {
            let targetX = (input.anchorX != nil && input.anchorX! > 0) ? input.anchorX! : input.mouseLocation.x
            var computedX = targetX - input.bodyWidth / 2.0 - (input.connected ? filletR : 0.0)
            computedX = max(visibleFrame.minX + 8, min(visibleFrame.maxX - totalWidth - 8, computedX))
            xPos = computedX

            let barTop = barFrame.height > 0 ? barFrame.maxY : (fullFrame.minY + 8 + input.barHeight)
            yPos = input.connected ? barTop : min(visibleFrame.maxY - totalHeight - gap, barTop + gap)
        } else {
            // Top bar
            let targetX = (input.anchorX != nil && input.anchorX! > 0) ? input.anchorX! : input.mouseLocation.x
            var computedX = targetX - input.bodyWidth / 2.0 - (input.connected ? filletR : 0.0)
            computedX = max(visibleFrame.minX + 8, min(visibleFrame.maxX - totalWidth - 8, computedX))
            xPos = computedX

            let barBottom = barFrame.height > 0 ? barFrame.minY : (fullFrame.maxY - 8 - input.barHeight)
            yPos = input.connected ? (barBottom - totalHeight) : max(visibleFrame.minY + gap, barBottom - totalHeight - gap)
        }

        return CGRect(x: xPos, y: yPos, width: totalWidth, height: totalHeight)
    }

    /// Convenience overload taking an `NSScreen` for its frames and the current mouse location.
    public static func frame(
        bodyWidth: CGFloat,
        bodyHeight: CGFloat,
        anchorX: CGFloat? = nil,
        screen: NSScreen,
        barPosition: String = "top",
        connected: Bool = false,
        filletRadius: CGFloat = 14,
        barFrame: CGRect = .zero,
        marginX: CGFloat = 8,
        isControlCenter: Bool = false,
        anchorToControlCenter: Bool = false,
        controlCenterFrame: CGRect = .zero
    ) -> NSRect {
        let input = PopoutLayoutInput(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            anchorX: anchorX,
            barPosition: barPosition,
            connected: connected,
            filletRadius: filletRadius,
            barFrame: barFrame,
            visibleFrame: screen.visibleFrame,
            fullFrame: screen.frame,
            mouseLocation: NSEvent.mouseLocation,
            marginX: marginX,
            isControlCenter: isControlCenter,
            anchorToControlCenter: anchorToControlCenter,
            controlCenterFrame: controlCenterFrame
        )
        let f = frame(for: input)
        return NSRect(x: f.minX, y: f.minY, width: f.width, height: f.height)
    }
}

// MARK: - Popout Animation Helper (SURF-002 Motion Architecture)

/// Pure motion choreography for popouts per DMS specification `SURF-002`:
/// popouts protrude out of the bar edge into the screen —
/// - Entrance: grows outward from the bar seam, scale 0.94→1.0 (or 0.05→1.0 on the bar
///   axis for vertical bars), opacity 0→1 over 250ms with M3 `emphasizedDecel`.
/// - Exit: retracts back into the bar edge over 180ms with M3 `emphasizedAccel`.
/// Generalized from DMS `PopoutAnimationHelper` as pure, testable math.
public enum PopoutAnimationHelper {
    public static let entranceDuration: Double = 0.250
    public static let exitDuration: Double = 0.180

    public static var entranceCurve: MaterialBezierCurve { .emphasizedDecel }
    public static var exitCurve: MaterialBezierCurve { .emphasizedAccel }

    /// SwiftUI animation for the entrance (grow out of the bar seam).
    public static func entranceAnimation(duration: Double = entranceDuration) -> Animation {
        let c = entranceCurve
        return .timingCurve(c.c1x, c.c1y, c.c2x, c.c2y, duration: duration)
    }

    /// SwiftUI animation for the exit (retract into the bar seam).
    public static func exitAnimation(duration: Double = exitDuration) -> Animation {
        let c = exitCurve
        return .timingCurve(c.c1x, c.c1y, c.c2x, c.c2y, duration: duration)
    }

    /// M3 Expressive spatial physics spring for popout protrusion (`defaultSpatial`: ζ=0.8, k=380).
    public static func expressiveSpatialAnimation(scheme: MaterialMotionScheme = .expressive) -> Animation {
        scheme.defaultSpatial.animation
    }

    /// M3 Expressive effects physics spring for popout opacity (`fastEffects`: ζ=1.0, k=3800, no overshoot).
    public static func expressiveEffectsAnimation(scheme: MaterialMotionScheme = .expressive) -> Animation {
        scheme.fastEffects.animation
    }

    /// Scale factors (x, y) for the protrusion animation. On the axis perpendicular to the
    /// bar the popout grows from 0.05; along the bar axis it scales 0.94→1.0.
    public static func scale(isVerticalBar: Bool, presented: Bool) -> CGSize {
        if isVerticalBar {
            return CGSize(width: presented ? 1.0 : 0.05, height: presented ? 1.0 : 0.94)
        }
        return CGSize(width: presented ? 1.0 : 0.94, height: presented ? 1.0 : 0.05)
    }

    /// Opacity for the protrusion animation.
    public static func opacity(presented: Bool) -> Double {
        presented ? 1.0 : 0.0
    }

    /// Collapsed frame size along the protrusion axis when hidden.
    public static func collapsedSize(isVerticalBar: Bool, total: CGSize, presented: Bool) -> CGSize {
        if presented {
            return total
        }
        if isVerticalBar {
            return CGSize(width: 0, height: total.height)
        }
        return CGSize(width: total.width, height: 0)
    }
}

// MARK: - Popout Surface Container (SURF-001 / SURF-002)

/// Reusable container view for popouts and overlay panels. In connected ("gothic")
/// mode it renders continuous concave fillet arcs (`GothEarCornerShape`) bridging the
/// popout surface directly into the attached bar. Fully decoupled from DMS window
/// controllers: dismissal, hover, and blur/surface configuration are explicit parameters,
/// colors come from `@Environment(\.materialTheme)`.
/// Generalized from DMS `PopoutSurfaceContainer`.
public struct MaterialPopoutSurfaceContainer<Content: View>: View {
    public var bodyWidth: CGFloat
    public var bodyHeight: CGFloat
    public var cornerRadius: CGFloat
    /// Edge of the screen/bar the popout protrudes from.
    public var edge: MaterialEdge
    /// Connected mode: flush attachment with gothic fillet flanges.
    public var connected: Bool
    public var filletRadius: CGFloat
    public var blurEnabled: Bool
    public var surfaceOpacity: Double?
    public var onDismiss: (() -> Void)?
    public var onHoverChange: ((Bool) -> Void)?
    @ViewBuilder public let content: () -> Content

    @Environment(\.materialTheme) private var theme: MaterialTheme
    @State private var isPresented: Bool = false

    public init(
        bodyWidth: CGFloat,
        bodyHeight: CGFloat,
        cornerRadius: CGFloat = 18,
        edge: MaterialEdge = .top,
        connected: Bool = false,
        filletRadius: CGFloat = 14,
        blurEnabled: Bool = true,
        surfaceOpacity: Double? = nil,
        onDismiss: (() -> Void)? = nil,
        onHoverChange: ((Bool) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.bodyWidth = bodyWidth
        self.bodyHeight = bodyHeight
        self.cornerRadius = cornerRadius
        self.edge = edge
        self.connected = connected
        self.filletRadius = max(4.0, filletRadius)
        self.blurEnabled = blurEnabled
        self.surfaceOpacity = surfaceOpacity
        self.onDismiss = onDismiss
        self.onHoverChange = onHoverChange
        self.content = content
    }

    private var isVertical: Bool {
        edge == .left || edge == .right
    }

    private var totalWidth: CGFloat {
        (connected && !isVertical) ? (bodyWidth + 2 * filletRadius) : bodyWidth
    }

    private var totalHeight: CGFloat {
        (connected && isVertical) ? (bodyHeight + 2 * filletRadius) : bodyHeight
    }

    private var protrusionAlignment: Alignment {
        switch edge {
        case .top: return .top
        case .left: return .leading
        case .right: return .trailing
        case .bottom: return .bottom
        }
    }

    private var scaleAnchor: UnitPoint {
        switch edge {
        case .top: return .top
        case .left: return .leading
        case .right: return .trailing
        case .bottom: return .bottom
        }
    }

    private var shape: GothEarCornerShape {
        GothEarCornerShape(
            edge: edge,
            cornerStyle: connected ? .gothic : .rounded,
            cornerRadius: cornerRadius,
            filletRadius: filletRadius,
            isVertical: isVertical,
            closedSeam: true
        )
    }

    /// Requests dismissal: plays the exit animation, then invokes `onDismiss`.
    public func dismiss() {
        withAnimation(PopoutAnimationHelper.exitAnimation()) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + PopoutAnimationHelper.exitDuration) {
            onDismiss?()
        }
    }

    public var body: some View {
        let scale = PopoutAnimationHelper.scale(isVerticalBar: isVertical, presented: isPresented)
        let collapsed = PopoutAnimationHelper.collapsedSize(isVerticalBar: isVertical, total: CGSize(width: totalWidth, height: totalHeight), presented: isPresented)

        ZStack(alignment: protrusionAlignment) {
            ZStack(alignment: protrusionAlignment) {
                ZStack {
                    content()
                        .frame(width: bodyWidth, height: bodyHeight)
                        .padding(.horizontal, (connected && !isVertical) ? filletRadius : 0)
                        .padding(.vertical, (connected && isVertical) ? filletRadius : 0)
                }
                .frame(width: totalWidth, height: totalHeight)
                .background(
                    GlassSurfaceBackground(
                        surfaceOpacity: surfaceOpacity,
                        blurEnabled: blurEnabled
                    )
                )
                .clipShape(shape)
                .overlay(
                    GothEarCornerShape(
                        edge: edge,
                        cornerStyle: connected ? .gothic : .rounded,
                        cornerRadius: cornerRadius,
                        filletRadius: filletRadius,
                        isVertical: isVertical,
                        closedSeam: !connected
                    )
                    .stroke(theme.panelBorderColor, lineWidth: 1)
                )
                .shadow(
                    color: theme.adaptiveShadowColor(baseOpacity: connected ? 0.25 : 0.35),
                    radius: 18,
                    x: 0,
                    y: edge == .bottom ? -4 : 8
                )
            }
            .frame(
                width: isVertical ? collapsed.width : totalWidth,
                height: !isVertical ? collapsed.height : totalHeight,
                alignment: protrusionAlignment
            )
            .clipped()
            .scaleEffect(x: scale.width, y: scale.height, anchor: scaleAnchor)
            .opacity(PopoutAnimationHelper.opacity(presented: isPresented))
        }
        .frame(width: totalWidth, height: totalHeight, alignment: protrusionAlignment)
        .onHover { hovered in
            onHoverChange?(hovered)
        }
        .onAppear {
            withAnimation(PopoutAnimationHelper.entranceAnimation()) {
                isPresented = true
            }
        }
    }
}
