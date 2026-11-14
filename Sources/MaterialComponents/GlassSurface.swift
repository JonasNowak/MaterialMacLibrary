import SwiftUI
import AppKit
import MaterialTokens

/// Native `NSVisualEffectView` wrapper for behind-window desktop blurring.
/// Appearance (Light/Dark vibrancy) is driven entirely by `@Environment(\.materialTheme)` —
/// no global stores. Generalized from DMS `VisualEffectBlur`.
public struct VisualEffectBlur: NSViewRepresentable {
    public var material: NSVisualEffectView.Material
    public var blendingMode: NSVisualEffectView.BlendingMode
    public var blurEnabled: Bool

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        material: NSVisualEffectView.Material = .popover,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        blurEnabled: Bool = true
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.blurEnabled = blurEnabled
    }

    private var resolvedMaterial: NSVisualEffectView.Material {
        if theme.isLightMode {
            // In AppKit Light Mode, .hudWindow is forced dark charcoal and .headerView is flat
            // opaque gray. .popover produces clean, bright, translucent Apple frosted glass.
            if material == .hudWindow || material == .headerView {
                return .popover
            }
            return material
        } else {
            if material == .headerView {
                return .popover
            }
            return material
        }
    }

    private var targetAppearance: NSAppearance? {
        NSAppearance(named: theme.isLightMode ? .aqua : .darkAqua)
    }

    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = resolvedMaterial
        view.blendingMode = blendingMode
        view.state = blurEnabled ? .active : .inactive
        view.isEmphasized = true
        view.appearance = targetAppearance
        return view
    }

    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        if let targetAppearance, nsView.appearance?.name != targetAppearance.name {
            nsView.appearance = targetAppearance
        }
        nsView.material = resolvedMaterial
        nsView.blendingMode = blendingMode
        let targetState: NSVisualEffectView.State = blurEnabled ? .active : .inactive
        if nsView.state != targetState {
            nsView.state = targetState
        }
    }
}

/// Unified Material 3 + macOS frosted glass surface background.
/// Layers behind-window `VisualEffectBlur` underneath the theme tonal tint, with a solid
/// `fallbackColor` used when blurring is disabled. All parameters are optional and default
/// to `@Environment(\.materialTheme)` values. Generalized from DMS `GlassSurfaceBackground`.
public struct GlassSurfaceBackground: View {
    /// When set, the surface is clipped to a continuous rounded rectangle of this radius.
    public var cornerRadius: CGFloat?
    /// Surface opacity 0...1. Defaults to the theme's popup/surface opacity tokens.
    public var surfaceOpacity: Double?
    /// Whether the behind-window blur layer is active. When `false`, only the solid
    /// fallback/tint layers render.
    public var blurEnabled: Bool
    /// Forces translucent frosted glass even when `surfaceOpacity >= 1.0` (e.g. transparent bars/popouts).
    public var forceGlass: Bool
    /// Optional tonal tint overlaid on the glass. Defaults to the theme surface tint.
    public var tintColor: Color?
    /// Solid base color used when blur is disabled or surface is opaque. Defaults to the
    /// theme's adaptive surface container color.
    public var fallbackColor: Color?
    public var material: NSVisualEffectView.Material

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        cornerRadius: CGFloat? = nil,
        surfaceOpacity: Double? = nil,
        blurEnabled: Bool = true,
        forceGlass: Bool = false,
        tintColor: Color? = nil,
        fallbackColor: Color? = nil,
        material: NSVisualEffectView.Material = .popover
    ) {
        self.cornerRadius = cornerRadius
        self.surfaceOpacity = surfaceOpacity
        self.blurEnabled = blurEnabled
        self.forceGlass = forceGlass
        self.tintColor = tintColor
        self.fallbackColor = fallbackColor
        self.material = material
    }

    private var resolvedBaseColor: Color {
        if let fallbackColor {
            return fallbackColor
        }
        return theme.isLightMode ? theme.palette.surfaceContainerLowestColor : theme.palette.surfaceContainerColor
    }

    private var resolvedTintColor: Color {
        tintColor ?? theme.surfaceTint
    }

    private var slider: Double {
        let raw = surfaceOpacity ?? min(theme.surfaceTokens.popupTransparency, theme.surfaceTokens.surfaceOpacity)
        return max(0.0, min(1.0, raw))
    }

    public var body: some View {
        let s = slider
        let isGlassActive = blurEnabled && (forceGlass || s < 0.999)
        let surface = Group {
            if s <= 0.005 {
                Color.clear
            } else if isGlassActive {
                ZStack {
                    // The blur effect itself scales with slider opacity down to 0
                    VisualEffectBlur(
                        material: theme.isLightMode ? .popover : material,
                        blendingMode: .behindWindow,
                        blurEnabled: blurEnabled
                    )
                    .opacity(min(1.0, s / 0.35))

                    if theme.isLightMode {
                        // Luminosity lift keeps Light Mode frosted glass bright and crisp over
                        // dark wallpapers, smoothly scaling to zero when the slider reaches 0.
                        let whiteLift = forceGlass ? (s * 0.40) : (s * 0.42)
                        let tintAlpha = forceGlass ? (s * 0.65) : min(0.94, s * 0.90)
                        Color.white.opacity(whiteLift)
                        resolvedBaseColor.opacity(tintAlpha)
                        resolvedTintColor.opacity(0.08 * s)

                        // Subtle top-to-bottom glass sheen scaled with slider
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.32 * s),
                                Color.white.opacity(0.04 * s)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        let tintAlpha = forceGlass ? (s * 0.72) : s
                        resolvedBaseColor.opacity(tintAlpha)
                        resolvedTintColor.opacity(0.06 * s)

                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.07 * s),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
            } else {
                resolvedBaseColor.opacity(s)
            }
        }

        if let cornerRadius {
            surface
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            surface
        }
    }
}
