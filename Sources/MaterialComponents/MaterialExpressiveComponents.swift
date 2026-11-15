import SwiftUI
import Combine
import MaterialTokens
import MaterialShapes

// MARK: - M3 Expressive Loading Indicator

/// Google Material 3 Expressive indeterminate loading indicator that continuously rotates and
/// morphs its silhouette through a sequence of expressive geometric shapes (`softBurst` →
/// `cookie9` → `pentagon` → `pill` → `sunny` → `cookie4` → `oval`).
public struct MaterialLoadingIndicator: View {
    public var shapes: [MaterialExpressiveShape]
    public var contained: Bool
    public var size: CGFloat
    public var isAnimating: Bool

    @Environment(\.materialTheme) private var theme: MaterialTheme
    @State private var morphPhase: CGFloat = 0.0
    @State private var rotationDegrees: Double = 0.0
    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    public init(
        shapes: [MaterialExpressiveShape] = AvatarShapeGenerator.loadingIndicatorCycle,
        contained: Bool = false,
        size: CGFloat = 48,
        isAnimating: Bool = true
    ) {
        self.shapes = shapes.isEmpty ? AvatarShapeGenerator.loadingIndicatorCycle : shapes
        self.contained = contained
        self.size = max(16, size)
        self.isAnimating = isAnimating
    }

    public var body: some View {
        let shapeSize = contained ? size * 0.64 : size * 0.80
        ZStack {
            if contained {
                Circle()
                    .fill(theme.primaryContainer)
                    .frame(width: size, height: size)
            }

            MaterialMorphingShape(shapes: shapes, progress: morphPhase)
                .fill(contained ? theme.onPrimaryContainer : theme.primary)
                .frame(width: shapeSize, height: shapeSize)
                .rotationEffect(.degrees(rotationDegrees))
        }
        .frame(width: size, height: size)
        .onReceive(timer) { _ in
            guard isAnimating, !theme.motionTokens.reducedMotion else { return }
            let speed = max(0.1, theme.motionTokens.animationSpeed)
            morphPhase += CGFloat(0.045 * speed)
            if morphPhase >= CGFloat(shapes.count) {
                morphPhase -= CGFloat(shapes.count)
            }
            rotationDegrees = (rotationDegrees + 2.4 * speed).truncatingRemainder(dividingBy: 360.0)
        }
    }
}

// MARK: - M3 Expressive Split Button

/// Visual emphasis style for `MaterialSplitButton`.
public enum MaterialSplitButtonStyle: String, Sendable, Codable, Equatable, CaseIterable {
    case filled
    case tonal
    case elevated
}

/// Google Material 3 Expressive two-segment split button: a leading primary action paired with
/// a connected trailing menu button whose corners morph into a circle and whose chevron rotates
/// 180° when `isMenuExpanded` is true.
public struct MaterialSplitButton: View {
    public let title: String
    public let icon: String?
    public let isMenuExpanded: Bool
    public let style: MaterialSplitButtonStyle
    public let onPrimaryTap: () -> Void
    public let onMenuTap: () -> Void

    @Environment(\.materialTheme) private var theme: MaterialTheme
    @State private var isPrimaryPressed = false

    public init(
        title: String,
        icon: String? = nil,
        isMenuExpanded: Bool = false,
        style: MaterialSplitButtonStyle = .filled,
        onPrimaryTap: @escaping () -> Void,
        onMenuTap: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isMenuExpanded = isMenuExpanded
        self.style = style
        self.onPrimaryTap = onPrimaryTap
        self.onMenuTap = onMenuTap
    }

    private var containerColor: Color {
        switch style {
        case .filled: return theme.primary
        case .tonal: return theme.secondaryContainer
        case .elevated: return theme.surfaceContainerHigh
        }
    }

    private var contentColor: Color {
        switch style {
        case .filled: return theme.onPrimary
        case .tonal: return theme.onSecondaryContainer
        case .elevated: return theme.primary
        }
    }

    public var body: some View {
        let outerRadius: CGFloat = 18
        let innerLeadingRadius: CGFloat = isPrimaryPressed ? 10 : 4
        let trailingInnerRadius: CGFloat = isMenuExpanded ? outerRadius : 4

        HStack(spacing: 2) {
            // Leading primary action segment
            Button {
                onPrimaryTap()
            } label: {
                HStack(spacing: 6) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 13, weight: .bold))
                    }
                    Text(title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(contentColor)
                .padding(.leading, 16)
                .padding(.trailing, 12)
                .frame(height: 36)
                .background(containerColor)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: outerRadius,
                        bottomLeadingRadius: outerRadius,
                        bottomTrailingRadius: innerLeadingRadius,
                        topTrailingRadius: innerLeadingRadius
                    )
                )
                .animation(theme.fastSpatialAnimation, value: isPrimaryPressed)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPrimaryPressed = true }
                    .onEnded { _ in isPrimaryPressed = false }
            )

            // Trailing menu trigger segment (morphs to circle when menu is expanded)
            Button {
                onMenuTap()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(contentColor)
                    .rotationEffect(.degrees(isMenuExpanded ? 180 : 0))
                    .frame(width: 36, height: 36)
                    .background(containerColor)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: trailingInnerRadius,
                            bottomLeadingRadius: trailingInnerRadius,
                            bottomTrailingRadius: outerRadius,
                            topTrailingRadius: outerRadius
                        )
                    )
                    .animation(theme.fastSpatialAnimation, value: isMenuExpanded)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - M3 Expressive Connected Button Group

/// One item in a `MaterialButtonGroup`.
public struct MaterialButtonGroupItem: Identifiable {
    public var id: String
    public var title: String
    public var icon: String?
    public var isSelected: Bool
    public var onTap: () -> Void

    public init(
        id: String? = nil,
        title: String,
        icon: String? = nil,
        isSelected: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.id = id ?? "\(icon ?? ""):\(title)"
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.onTap = onTap
    }
}

/// Google Material 3 Expressive connected button group with reactive corner-radius morphing
/// and width expansion on active/selected segments.
public struct MaterialButtonGroup: View {
    public let items: [MaterialButtonGroupItem]

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(items: [MaterialButtonGroupItem]) {
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let isFirst = index == 0
                let isLast = index == items.count - 1
                let outerR: CGFloat = 18
                let innerR: CGFloat = item.isSelected ? 18 : 4

                Button {
                    item.onTap()
                } label: {
                    HStack(spacing: 6) {
                        if let icon = item.icon {
                            Image(systemName: icon)
                                .font(.system(size: 12, weight: item.isSelected ? .bold : .semibold))
                        }
                        Text(item.title)
                            .font(.system(size: 12, weight: item.isSelected ? .bold : .medium, design: .rounded))
                    }
                    .foregroundColor(item.isSelected ? theme.onPrimary : theme.onSecondaryContainer)
                    .padding(.horizontal, item.isSelected ? 16 : 12)
                    .frame(height: 36)
                    .background(item.isSelected ? theme.primary : theme.secondaryContainer)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: isFirst ? outerR : innerR,
                            bottomLeadingRadius: isFirst ? outerR : innerR,
                            bottomTrailingRadius: isLast ? outerR : innerR,
                            topTrailingRadius: isLast ? outerR : innerR
                        )
                    )
                    .animation(theme.fastSpatialAnimation, value: item.isSelected)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - M3 Expressive Floating Toolbar

/// Color theme variant for `MaterialFloatingToolbar`.
public enum MaterialToolbarStyle: String, Sendable, Codable, Equatable, CaseIterable {
    /// High-surface container background (`surfaceContainerHigh`).
    case standard
    /// Vibrant accent container background (`primaryContainer`).
    case vibrant
}

/// One action item inside `MaterialFloatingToolbar`.
public struct MaterialToolbarItem: Identifiable {
    public var id: String
    public var icon: String
    public var label: String
    public var isActive: Bool
    public var onTap: () -> Void

    public init(
        id: String? = nil,
        icon: String,
        label: String = "",
        isActive: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.id = id ?? "\(icon):\(label)"
        self.icon = icon
        self.label = label
        self.isActive = isActive
        self.onTap = onTap
    }
}

/// Google Material 3 Expressive floating pill toolbar supporting horizontal or vertical layout,
/// standard or vibrant container styling, and an optional trailing/bottom FAB slot.
public struct MaterialFloatingToolbar: View {
    public let items: [MaterialToolbarItem]
    public let style: MaterialToolbarStyle
    public let isVertical: Bool
    public let fabIcon: String?
    public let onFabTap: (() -> Void)?

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        items: [MaterialToolbarItem],
        style: MaterialToolbarStyle = .standard,
        isVertical: Bool = false,
        fabIcon: String? = nil,
        onFabTap: (() -> Void)? = nil
    ) {
        self.items = items
        self.style = style
        self.isVertical = isVertical
        self.fabIcon = fabIcon
        self.onFabTap = onFabTap
    }

    private var toolbarBackground: Color {
        style == .vibrant ? theme.primaryContainer : theme.surfaceContainerHigh
    }

    private var activeButtonBackground: Color {
        style == .vibrant ? theme.primary : theme.secondaryContainer
    }

    private var activeButtonForeground: Color {
        style == .vibrant ? theme.onPrimary : theme.onSecondaryContainer
    }

    private var inactiveButtonForeground: Color {
        style == .vibrant ? theme.onPrimaryContainer : theme.onSurfaceVariant
    }

    public var body: some View {
        let layout = isVertical
            ? AnyLayout(VStackLayout(spacing: 8))
            : AnyLayout(HStackLayout(spacing: 8))

        layout {
            let itemsLayout = isVertical
                ? AnyLayout(VStackLayout(spacing: 4))
                : AnyLayout(HStackLayout(spacing: 4))

            itemsLayout {
                ForEach(items) { item in
                    Button {
                        item.onTap()
                    } label: {
                        Image(systemName: item.icon)
                            .font(.system(size: 14, weight: item.isActive ? .bold : .semibold))
                            .foregroundColor(item.isActive ? activeButtonForeground : inactiveButtonForeground)
                            .frame(width: 36, height: 36)
                            .background(item.isActive ? activeButtonBackground : Color.clear)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: item.isActive ? 12 : 18,
                                    style: .continuous
                                )
                            )
                            .animation(theme.fastSpatialAnimation, value: item.isActive)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .background(toolbarBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(theme.panelBorderColor, lineWidth: 1)
            )
            .shadow(color: theme.adaptiveShadowColor(baseOpacity: 0.25), radius: 12, x: 0, y: 4)

            if let fabIcon, let onFabTap {
                Button {
                    onFabTap()
                } label: {
                    Image(systemName: fabIcon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.onPrimary)
                        .frame(width: 48, height: 48)
                        .background(theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: theme.adaptiveShadowColor(baseOpacity: 0.30), radius: 12, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
