import SwiftUI
import MaterialTokens

// MARK: - Toast Card

/// Floating toast pill with icon and message over frosted glass.
/// Generalized from DMS `ToastOverlayView`'s toast card.
public struct MaterialToastCard: View {
    public let icon: String
    public let message: String
    public var blurEnabled: Bool

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(icon: String, message: String, blurEnabled: Bool = true) {
        self.icon = icon
        self.message = message
        self.blurEnabled = blurEnabled
    }

    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.primary)

            Text(message)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(theme.onSurface)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(GlassSurfaceBackground(blurEnabled: blurEnabled))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(theme.panelBorderColor, lineWidth: 1)
        )
        .shadow(color: theme.adaptiveShadowColor(baseOpacity: 0.28), radius: 15, x: 0, y: 6)
    }
}

// MARK: - OSD Pill

/// On-screen display pill: icon plus either a gauge with readout (brightness/volume) or a
/// title/value stack. Generalized from DMS `OSDView`.
public struct MaterialOSDPill: View {
    public let icon: String
    /// When non-nil, renders the M3 gauge track with fill and a monospaced readout.
    public let value: Double?
    public let title: String
    public let formattedValue: String
    public var width: CGFloat
    public var blurEnabled: Bool

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        icon: String,
        value: Double? = nil,
        title: String = "",
        formattedValue: String = "",
        width: CGFloat = 260,
        blurEnabled: Bool = true
    ) {
        self.icon = icon
        self.value = value.map { min(1.0, max(0.0, $0)) }
        self.title = title
        self.formattedValue = formattedValue
        self.width = width
        self.blurEnabled = blurEnabled
    }

    /// The gauge value clamped into 0...1 (nil when not a gauge metric).
    public var clampedValue: Double? {
        value.map { min(1.0, max(0.0, $0)) }
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(theme.primary)
                .frame(width: 24)

            if let val = clampedValue {
                // M3 progress track
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(theme.surfaceContainerHighest)

                        Capsule()
                            .fill(theme.primary)
                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(val))))
                    }
                }
                .frame(height: 8)

                Text(formattedValue)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.onSurface)
                    .frame(width: 44, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    if !title.isEmpty {
                        Text(title)
                            .font(theme.font(size: 10, weight: .medium))
                            .foregroundColor(theme.onSurfaceVariant)
                    }
                    Text(formattedValue)
                        .font(theme.font(size: 13, weight: .bold))
                        .foregroundColor(theme.onSurface)
                        .lineLimit(1)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: width)
        .background(GlassSurfaceBackground(blurEnabled: blurEnabled))
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(theme.panelBorderColor, lineWidth: 1)
        )
        .shadow(color: theme.adaptiveShadowColor(baseOpacity: 0.28), radius: 15, x: 0, y: 6)
    }
}

// MARK: - Action Tile

/// Circular icon action tile with hover highlight, used in power/session menus.
/// Generalized from DMS `PowerOptionButton`.
public struct MaterialActionTile: View {
    public let icon: String
    public let label: String
    public let color: Color
    public let action: () -> Void

    @Environment(\.materialTheme) private var theme: MaterialTheme
    @State private var isHovered = false

    public init(icon: String, label: String, color: Color? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.color = color ?? .accentColor
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(isHovered ? color.opacity(0.2) : theme.surfaceContainerHigh)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(color.opacity(0.4), lineWidth: 1)
                    )

                Text(label)
                    .font(.system(size: 9.5, weight: .bold, design: .rounded))
                    .foregroundColor(theme.onSurface)
            }
        }
        .buttonStyle(.plain)
        .onHover { h in isHovered = h }
    }
}
