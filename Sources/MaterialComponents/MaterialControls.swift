import SwiftUI
import MaterialTokens
import MaterialShapes

// MARK: - Header Action Button

/// Circular icon-only header action button with M3 Expressive hover/press corner morphing.
/// Generalized from DMS `HeaderActionButton`.
public struct MaterialHeaderActionButton: View {
    public let icon: String
    public let action: () -> Void

    @Environment(\.materialTheme) private var theme: MaterialTheme
    @State private var isHovered = false

    public init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isHovered ? theme.onSurface : theme.onSurfaceVariant)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: isHovered ? 9 : 14, style: .continuous)
                        .fill(isHovered ? theme.surfaceContainerHighest.opacity(0.65) : Color.clear)
                )
                .animation(theme.fastSpatialAnimation, value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Pill Slider

/// M3 Expressive dual pill slider (split track gap + stop dot + spring-animated vertical thumb).
/// Generalized from DMS `ControlCenterPillSlider`.
public struct MaterialPillSlider: View {
    public let icon: String
    public let value: Double
    public let onIconTap: () -> Void
    public let onValueChanged: (Double) -> Void

    @Environment(\.materialTheme) private var theme: MaterialTheme
    @State private var isDragging = false

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
                let thumbGap: CGFloat = 5.0
                let activeWidth = max(0, fillWidth - thumbGap)
                let inactiveWidth = max(0, width - fillWidth - thumbGap)

                ZStack(alignment: .leading) {
                    // Inactive remaining track segment (with M3 Expressive gap around handle)
                    if inactiveWidth > 2 {
                        Capsule()
                            .fill(theme.surfaceContainerHighest.opacity(0.85))
                            .frame(width: inactiveWidth, height: 10)
                            .offset(x: width - inactiveWidth)
                    }

                    // Active filled track segment
                    if activeWidth > 0 {
                        Capsule()
                            .fill(theme.primary.opacity(0.90))
                            .frame(width: activeWidth, height: 10)
                    }

                    // M3 Expressive end-of-track stop indicator dot
                    if clampedVal < 0.96 {
                        Circle()
                            .fill(theme.primary.opacity(0.55))
                            .frame(width: 4, height: 4)
                            .offset(x: max(0, width - 7))
                    }

                    // M3 Expressive vertical handle bar (expands vertically on drag)
                    Capsule()
                        .fill(theme.primary)
                        .frame(width: 4, height: isDragging ? 20 : 16)
                        .offset(x: max(0, min(width - 4, fillWidth - 2)))
                        .animation(theme.fastSpatialAnimation, value: isDragging)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            guard width > 0 else { return }
                            isDragging = true
                            let fraction = max(0.0, min(1.0, Double(gesture.location.x / width)))
                            onValueChanged(fraction)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
            }
            .frame(height: 20)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tile

/// Material 3 Expressive control-center tile with shape-morphing pill icon and emphasized labels.
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
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(theme.primary)
                            .frame(width: 58, height: 32)

                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.onPrimary)
                    } else {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(theme.surfaceContainerHighest.opacity(0.45))
                            .frame(width: 58, height: 32)

                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.onSurfaceVariant)
                    }
                }
                .animation(theme.fastSpatialAnimation, value: isActive)
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
        .clipShape(RoundedRectangle(cornerRadius: isActive ? 18 : 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: isActive ? 18 : 14, style: .continuous)
                .stroke(theme.outlineVariant.opacity(0.15), lineWidth: 1)
        )
        .animation(theme.fastSpatialAnimation, value: isActive)
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

/// Compact M3 Expressive icon button for `MaterialQuickTilesGrid`.
/// Morphs its container shape from a circle (`16pt` radius) when inactive into an M3 Expressive
/// squircle (`10pt` radius) when active, animated via `fastSpatialAnimation`.
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
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: item.isActive ? 10 : 16,
                            style: .continuous
                        )
                    )
                    .animation(theme.fastSpatialAnimation, value: item.isActive)

                Text(item.label)
                    .font(.system(size: 9, weight: item.isActive ? .bold : .medium, design: .rounded))
                    .foregroundColor(item.isActive ? theme.onSurface : theme.onSurfaceVariant)
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

/// Floating interactive edit bar for Control Center edit mode (Add/Reset/Done),
/// generalized from DMS `CcEditChrome`.
/// All colors come from `@Environment(\.materialTheme)`.
public struct MaterialFloatingEditChrome: View {
    public let addTitle: String
    public let onAdd: () -> Void
    public let onReset: (() -> Void)?
    public let onDone: () -> Void

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        addTitle: String = "Add",
        onAdd: @escaping () -> Void,
        onReset: (() -> Void)? = nil,
        onDone: @escaping () -> Void
    ) {
        self.addTitle = addTitle
        self.onAdd = onAdd
        self.onReset = onReset
        self.onDone = onDone
    }

    public var body: some View {
        barChrome
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
