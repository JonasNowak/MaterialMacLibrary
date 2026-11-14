import SwiftUI
import Combine
import MaterialTokens

/// Animated Material 3 expressive wavy ("squiggly") progress scrubber matching
/// Android 13/14 and DankDash design. `activeColor`/`trackColor` default to the
/// `@Environment(\.materialTheme)` primary and subtle track colors when not overridden.
/// Generalized from DMS `SquigglyProgressBar`.
public struct SquigglyProgressBar: View {
    public var progress: Double // 0.0 to 1.0 (clamped on init and on read)
    public var isPlaying: Bool
    public var activeColor: Color?
    public var trackColor: Color?
    public var onSeek: ((Double) -> Void)?

    /// Wave amplitude in points while playing.
    public var amplitude: CGFloat
    /// Horizontal length of one full sine wave in points.
    public var waveLength: CGFloat

    @Environment(\.materialTheme) private var theme: MaterialTheme
    @State private var wavePhase: Double = 0.0
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    public init(
        progress: Double,
        isPlaying: Bool = true,
        activeColor: Color? = nil,
        trackColor: Color? = nil,
        amplitude: CGFloat = 2.2,
        waveLength: CGFloat = 18.0,
        onSeek: ((Double) -> Void)? = nil
    ) {
        self.progress = SquigglyProgressBar.clamped(progress)
        self.isPlaying = isPlaying
        self.activeColor = activeColor
        self.trackColor = trackColor
        self.amplitude = amplitude
        self.waveLength = waveLength
        self.onSeek = onSeek
    }

    /// Clamps a raw progress value into the 0...1 range.
    public static func clamped(_ progress: Double) -> Double {
        min(1.0, max(0.0, progress))
    }

    /// The progress value clamped into 0...1.
    public var clampedProgress: Double {
        SquigglyProgressBar.clamped(progress)
    }

    private var resolvedActiveColor: Color {
        activeColor ?? theme.primary
    }

    private var resolvedTrackColor: Color {
        trackColor ?? theme.subtleTrackColor
    }

    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let midY = h / 2.0
            let playedWidth = max(0, min(w, w * CGFloat(clampedProgress)))
            let currentAmplitude: CGFloat = isPlaying ? amplitude : 0.0

            ZStack(alignment: .leading) {
                // Background remaining track (subtle straight horizontal line)
                if playedWidth < w {
                    Path { p in
                        p.move(to: CGPoint(x: playedWidth, y: midY))
                        p.addLine(to: CGPoint(x: w, y: midY))
                    }
                    .stroke(resolvedTrackColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                }

                // Material 3 squiggly played track
                Path { p in
                    let step: CGFloat = 2.0
                    var x: CGFloat = 0.0

                    p.move(to: CGPoint(x: 0, y: midY))
                    while x <= playedWidth {
                        let angle = (x / waveLength) * 2.0 * .pi + CGFloat(wavePhase)
                        let y = midY + sin(angle) * currentAmplitude
                        p.addLine(to: CGPoint(x: x, y: y))
                        x += step
                    }
                    // Connect smoothly to the thumb position
                    if currentAmplitude > 0 && playedWidth > 0 {
                        let finalAngle = (playedWidth / waveLength) * 2.0 * .pi + CGFloat(wavePhase)
                        let finalY = midY + sin(finalAngle) * currentAmplitude
                        p.addLine(to: CGPoint(x: playedWidth, y: finalY))
                    }
                }
                .stroke(resolvedActiveColor, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))

                // Subtle vertical needle marker (avoids an overly clickable / chunky slider knob)
                if clampedProgress > 0.01 && clampedProgress < 0.99 {
                    RoundedRectangle(cornerRadius: 1.0)
                        .fill(resolvedActiveColor)
                        .frame(width: 2.0, height: 10.5)
                        .position(x: playedWidth, y: midY)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard w > 0 else { return }
                        let newProg = SquigglyProgressBar.clamped(Double(max(0, min(1, value.location.x / w))))
                        onSeek?(newProg)
                    }
            )
        }
        .frame(height: 14)
        .onReceive(timer) { _ in
            if isPlaying {
                wavePhase += 0.12
                if wavePhase > 2.0 * .pi {
                    wavePhase -= 2.0 * .pi
                }
            }
        }
    }
}
