import SwiftUI
import MaterialTokens

// MARK: - Header Action Button

/// Circular icon-only header action button. Generalized from DMS `HeaderActionButton`.
public struct MaterialHeaderActionButton: View {
    public let icon: String
    public let action: () -> Void

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(theme.onSurfaceVariant)
                .frame(width: 28, height: 28)
                .background(Color.clear)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pill Slider

/// Dual pill slider (pill track + fill + needle thumb). Generalized from DMS
/// `ControlCenterPillSlider`.
public struct MaterialPillSlider: View {
    public let icon: String
    public let value: Double
    public let onIconTap: () -> Void
    public let onValueChanged: (Double) -> Void

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        icon: String,
        value: Double,
        onIconTap: @escaping () -> Void,
        onValueChanged: @escaping (Double) -> Void
    ) {
        self.icon = icon
        self.value = value
        self.onIconTap = onIconTap
        self.onValueChanged = onValueChanged
    }

    /// The slider value clamped into 0...1.
    public var clampedValue: Double {
        min(1.0, max(0.0, value))
    }

    public var body: some View {
        HStack(spacing: 8) {
            Button(action: onIconTap) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.onSurfaceVariant)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)

            GeometryReader { geo in
                let width = geo.size.width
                let clampedVal = clampedValue
                let fillWidth = width * CGFloat(clampedVal)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.surfaceContainerHighest.opacity(0.85))
                        .frame(height: 10)

                    Capsule()
                        .fill(theme.primary.opacity(0.85))
                        .frame(width: max(0, fillWidth), height: 10)

                    Capsule()
                        .fill(theme.onPrimary)
                        .frame(width: 4, height: 16)
                        .offset(x: max(0, min(width - 4, fillWidth - 2)))
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            guard width > 0 else { return }
                            let fraction = max(0.0, min(1.0, Double(gesture.location.x / width)))
                            onValueChanged(fraction)
                        }
                )
            }
            .frame(height: 18)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tile

/// Material 3 control-center tile with pill icon and clean labels.
/// Generalized from DMS `ControlCenterTile`.
public struct MaterialTile: View {
    public let icon: String
    public let title: String
    public let subtitle: String
    public let isActive: Bool
    public let hasDetail: Bool
    public let isPillIcon: Bool
    public let onTap: () -> Void
    public let onDetailTap: () -> Void

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        icon: String,
        title: String,
        subtitle: String = "",
        isActive: Bool,
        hasDetail: Bool = false,
        isPillIcon: Bool = true,
        onTap: @escaping () -> Void,
        onDetailTap: @escaping () -> Void = {}
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isActive = isActive
        self.hasDetail = hasDetail
        self.isPillIcon = isPillIcon
        self.onTap = onTap
        self.onDetailTap = onDetailTap
    }

    public var body: some View {
        HStack(spacing: 8) {
            Button {
                onTap()
            } label: {
                ZStack {
                    if isPillIcon && isActive {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(theme.primary)
                            .frame(width: 58, height: 32)

                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.onPrimary)
                    } else {
                        Color.clear
                            .frame(width: 58, height: 32)

                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.onSurfaceVariant)
                    }
                }
            }
            .buttonStyle(.plain)

            Button {
                if hasDetail {
                    onDetailTap()
                } else {
                    onTap()
                }
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(theme.onSurface)
                        .lineLimit(1)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(theme.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 6)
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
        .background(theme.surfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(theme.outlineVariant.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Detail Page

/// Container hosting a full detail subpage with breadcrumb navigation header
/// (Back, Title, Close). Generalized from DMS `CcDetailPage`.
public struct MaterialDetailPage<Content: View>: View {
    public let title: String
    public let onBack: () -> Void
    public let onClose: () -> Void
    @ViewBuilder public let content: () -> Content

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        title: String,
        onBack: @escaping () -> Void,
        onClose: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.onBack = onBack
        self.onClose = onClose
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Breadcrumb header
            HStack(spacing: 12) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(theme.onSurface)
                        .frame(width: 30, height: 30)
                        .background(theme.surfaceContainerHigh)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.escape, modifiers: [])

                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(theme.onSurface)

                Spacer()

                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(theme.onSurfaceVariant)
                        .frame(width: 26, height: 26)
                        .background(theme.surfaceContainerHigh)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(theme.surfaceContainerHigh.opacity(0.5))

            Divider()
                .background(theme.outlineVariant.opacity(0.3))

            ScrollView(.vertical, showsIndicators: true) {
                content()
                    .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.surfaceContainer)
    }
}

// MARK: - Quick Tiles Grid

/// One data-driven quick action tile (icon + label + active state + tap handler).
public struct MaterialQuickTileItem: Identifiable {
    public var id: String
    public var icon: String
    public var label: String
    public var isActive: Bool
    public var onTap: () -> Void

    public init(id: String? = nil, icon: String, label: String, isActive: Bool = false, onTap: @escaping () -> Void) {
        self.id = id ?? "\(icon):\(label)"
        self.icon = icon
        self.label = label
        self.isActive = isActive
        self.onTap = onTap
    }
}

/// Compact circular/rounded icon button for `MaterialQuickTilesGrid`.
/// Generalized from DMS `QuickTileButton`.
public struct MaterialQuickTileButton: View {
    public let item: MaterialQuickTileItem

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(item: MaterialQuickTileItem) {
        self.item = item
    }

    public var body: some View {
        Button {
            item.onTap()
        } label: {
            VStack(spacing: 3) {
                Image(systemName: item.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(item.isActive ? theme.onPrimary : theme.primary)
                    .frame(width: 32, height: 32)
                    .background(item.isActive ? theme.primary : theme.surfaceContainer)
                    .clipShape(Circle())

                Text(item.label)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(theme.onSurfaceVariant)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

/// Horizontal bundle of compact 1x1 quick action tiles inside a single rounded slot.
/// Generalized from DMS `QuickTilesGroup` (data-driven instead of hardcoded services).
public struct MaterialQuickTilesGrid: View {
    public let items: [MaterialQuickTileItem]

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(items: [MaterialQuickTileItem]) {
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(items) { item in
                MaterialQuickTileButton(item: item)
            }
        }
        .padding(6)
        .background(theme.surfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Floating Edit Chrome

/// Visual style of `MaterialFloatingEditChrome`.
public enum MaterialEditChromeStyle: String, Sendable, Codable, Equatable, CaseIterable {
    /// Rounded-rectangle bottom toolbar (Control Center edit mode).
    case bar
    /// Capsule floating bar with drop shadow (Dock edit mode).
    case capsule
}

/// Floating interactive edit bar generalizing DMS `CcEditChrome` (bar style with
/// Add/Reset/Done) and `DockEditChrome` (capsule style with title/Add/Settings/Done).
/// All colors come from `@Environment(\.materialTheme)`.
public struct MaterialFloatingEditChrome: View {
    public let title: String?
    public let addTitle: String
    public let onAdd: () -> Void
    public let onReset: (() -> Void)?
    public let onDone: () -> Void
    public let style: MaterialEditChromeStyle

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        title: String? = nil,
        addTitle: String = "Add",
        onAdd: @escaping () -> Void,
        onReset: (() -> Void)? = nil,
        onDone: @escaping () -> Void,
        style: MaterialEditChromeStyle = .bar
    ) {
        self.title = title
        self.addTitle = addTitle
        self.onAdd = onAdd
        self.onReset = onReset
        self.onDone = onDone
        self.style = style
    }

    public var body: some View {
        if style == .capsule {
            capsuleChrome
        } else {
            barChrome
        }
    }

    private var capsuleChrome: some View {
        HStack(spacing: 12) {
            if let title = title {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(theme.onPrimaryContainer)
                    .padding(.horizontal, 6)
            }

            Button {
                onAdd()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                    Text(addTitle)
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.onPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(theme.primary)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            if let onReset = onReset {
                Button {
                    onReset()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.onSurface)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(theme.surfaceContainerHigh)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Button {
                onDone()
            } label: {
                Text("Done")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(theme.onSecondaryContainer)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(theme.secondaryContainer)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(theme.surfaceContainer)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(theme.outlineVariant.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private var barChrome: some View {
        HStack(spacing: 8) {
            Button(action: onAdd) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                    Text(addTitle)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(theme.primaryContainer)
                .foregroundColor(theme.onPrimaryContainer)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            if let onReset = onReset {
                Button(action: onReset) {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.onSurfaceVariant)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(theme.surfaceContainerHighest)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Button(action: onDone) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                    Text("Done")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(theme.primary)
                .foregroundColor(theme.onPrimary)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(theme.surfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Hover Bounce

/// Two-phase directional hover bounce matching upstream `DockHoverBounce.qml`.
/// Displaces content toward screen center on hover:
/// `position`: 0 = top, 1 = bottom, 2 = left, 3 = right.
/// Generalized from DMS `DockHoverBounceModifier`; animation curves come from
/// `@Environment(\.materialTheme)` motion tokens.
public struct HoverBounceModifier: ViewModifier {
    public let isHovered: Bool
    public let position: Int // 0=top, 1=bottom, 2=left, 3=right
    public let enabled: Bool

    @Environment(\.materialTheme) private var theme: MaterialTheme
    @State private var bounceOffset: CGFloat = 0.0

    public init(isHovered: Bool, position: Int, enabled: Bool = true) {
        self.isHovered = isHovered
        self.position = position
        self.enabled = enabled
    }

    /// Whether the dock position is vertical (left/right).
    public static func isVerticalDock(position: Int) -> Bool {
        position == 2 || position == 3
    }

    /// Bounce direction: +1 for Top/Left, -1 for Bottom/Right (always toward screen center).
    public static func direction(for position: Int) -> CGFloat {
        (position == 0 || position == 2) ? 1.0 : -1.0
    }

    /// Steady-state hover offset magnitude in points (20% of the 10pt travel).
    public static var restOffset: CGFloat { 2.0 }
    /// Peak transient offset magnitude in points (25% of the 10pt travel).
    public static var peakOffset: CGFloat { 2.5 }

    private var isVertical: Bool {
        Self.isVerticalDock(position: position)
    }

    private var direction: CGFloat {
        Self.direction(for: position)
    }

    public func body(content: Content) -> some View {
        content
            .offset(
                x: isVertical ? bounceOffset : 0,
                y: isVertical ? 0 : bounceOffset
            )
            .onChange(of: isHovered) { _, hovered in
                guard enabled else {
                    bounceOffset = 0
                    return
                }
                if hovered {
                    // Phase 1: emphasized acceleration toward screen center
                    let curve = MaterialBezierCurve.emphasizedAccel
                    withAnimation(.timingCurve(curve.c1x, curve.c1y, curve.c2x, curve.c2y, duration: 0.15 * theme.motionTokens.durShort / 0.2)) {
                        bounceOffset = direction * Self.peakOffset
                    }
                    // Phase 2: settling to steady hover offset
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.timingCurve(0.05, 0.9, 0.1, 1.0, duration: 0.15)) {
                            bounceOffset = direction * Self.restOffset
                        }
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.15)) {
                        bounceOffset = 0
                    }
                }
            }
    }
}

public extension View {
    /// Applies the two-phase directional hover bounce (toward screen center).
    func materialHoverBounce(isHovered: Bool, position: Int, enabled: Bool = true) -> some View {
        modifier(HoverBounceModifier(isHovered: isHovered, position: position, enabled: enabled))
    }
}
