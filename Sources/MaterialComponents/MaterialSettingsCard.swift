import SwiftUI
import MaterialTokens

/// Material 3 card container for settings sections. Colors come from an explicit
/// `palette` when provided, otherwise from `@Environment(\.materialTheme)`.
/// Visual styling preserved from DMS `SettingsCard`.
public struct MaterialSettingsCard<Content: View>: View {
    public let icon: String?
    public let title: String?
    public let subtitle: String?
    public let palette: MaterialPalette?
    public let content: Content

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        icon: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        palette: MaterialPalette? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.palette = palette
        self.content = content()
    }

    private var p: MaterialPalette {
        palette ?? theme.palette
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = title {
                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(p.primaryColor)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(p.onSurfaceColor)
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 11))
                                .foregroundColor(p.outlineColor)
                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 2)
            }

            content
        }
        .padding(12)
        .background(
            !p.isDark
                ? p.surfaceContainerLowestColor.opacity(0.85)
                : p.surfaceContainerHighColor.opacity(0.75)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(p.outlineVariantColor.opacity(0.35), lineWidth: 1)
        )
    }
}

/// Material 3 segmented pill selector (e.g., [✓ Left | Right | Hidden]).
/// Visual styling preserved from DMS `SettingsSegmentedControl`.
public struct MaterialSegmentedControl<T: Hashable & Equatable>: View {
    public let options: [(title: String, value: T)]
    @Binding public var selection: T
    public let palette: MaterialPalette?

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        options: [(title: String, value: T)],
        selection: Binding<T>,
        palette: MaterialPalette? = nil
    ) {
        self.options = options
        self._selection = selection
        self.palette = palette
    }

    private var p: MaterialPalette {
        palette ?? theme.palette
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<options.count, id: \.self) { idx in
                let item = options[idx]
                let isSelected = selection == item.value

                Button(action: {
                    selection = item.value
                }) {
                    HStack(spacing: 5) {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(p.primaryColor)
                        }
                        Text(item.title)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? p.onPrimaryContainerColor : p.onSurfaceVariantColor)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        isSelected
                            ? p.primaryContainerColor
                            : p.surfaceContainerLowColor.opacity(0.6)
                    )
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(p.surfaceContainerLowColor)
        .cornerRadius(10)
    }
}

/// Material 3 slider row with title, live value readout, and explanatory subtext.
/// Visual styling preserved from DMS `SettingsSliderRow`.
public struct MaterialSliderRow: View {
    public let title: String
    public let valueFormatted: String
    @Binding public var value: Double
    public let range: ClosedRange<Double>
    public let step: Double
    public let helper: String?
    public let palette: MaterialPalette?

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        title: String,
        valueFormatted: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        helper: String? = nil,
        palette: MaterialPalette? = nil
    ) {
        self.title = title
        self.valueFormatted = valueFormatted
        self._value = value
        self.range = range
        self.step = step
        self.helper = helper
        self.palette = palette
    }

    private var p: MaterialPalette {
        palette ?? theme.palette
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(p.onSurfaceColor)
                Spacer()
                Text(valueFormatted)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(p.primaryColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(p.primaryContainerColor.opacity(0.5))
                    .cornerRadius(4)
            }

            Slider(value: $value, in: range, step: step)
                .tint(p.primaryColor)

            if let helper = helper {
                Text(helper)
                    .font(.system(size: 10))
                    .foregroundColor(p.outlineColor)
            }
        }
    }
}

/// Material 3 toggle row with title, description, and switch.
/// Visual styling preserved from DMS `SettingsToggleRow`.
public struct MaterialToggleRow: View {
    public let title: String
    public let subtitle: String?
    @Binding public var isOn: Bool
    public let palette: MaterialPalette?

    @Environment(\.materialTheme) private var theme: MaterialTheme

    public init(
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>,
        palette: MaterialPalette? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.palette = palette
    }

    private var p: MaterialPalette {
        palette ?? theme.palette
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(p.onSurfaceColor)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(p.outlineColor)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(p.primaryColor)
                .labelsHidden()
        }
    }
}
