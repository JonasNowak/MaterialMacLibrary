import SwiftUI
import CoreGraphics
import MaterialTokens

/// SwiftUI Shape wrapping `AvatarShapeGenerator` for all 35 Material 3 Expressive shapes.
public struct GeometricAvatarShape: Shape {
    public let shapeName: String

    public init(shapeName: String) {
        self.shapeName = shapeName
    }

    public init(shape: MaterialExpressiveShape) {
        self.shapeName = shape.rawValue
    }

    public func path(in rect: CGRect) -> Path {
        let cgPath = AvatarShapeGenerator.path(for: shapeName, in: rect)
        return Path(cgPath)
    }
}

/// Animatable SwiftUI Shape that smoothly morphs between two Material 3 Expressive shapes
/// (`from` at `progress = 0` → `to` at `progress = 1`), or cycles through an array of shapes.
public struct MaterialMorphingShape: Shape {
    public var shapes: [MaterialExpressiveShape]
    public var progress: CGFloat

    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    /// Creates a morphing shape between two M3 Expressive shapes (`progress` in `0...1`).
    public init(
        from: MaterialExpressiveShape,
        to: MaterialExpressiveShape,
        progress: CGFloat = 0.0
    ) {
        self.shapes = [from, to]
        self.progress = progress
    }

    /// Creates a multi-stage morphing shape cycling through `shapes` (`progress` in `0..<CGFloat(shapes.count)`).
    public init(
        shapes: [MaterialExpressiveShape] = AvatarShapeGenerator.loadingIndicatorCycle,
        progress: CGFloat = 0.0
    ) {
        self.shapes = shapes.isEmpty ? [.circle] : shapes
        self.progress = progress
    }

    public func path(in rect: CGRect) -> Path {
        if shapes.count == 2 {
            return Path(
                AvatarShapeGenerator.morphedPath(
                    from: shapes[0],
                    to: shapes[1],
                    progress: progress,
                    in: rect
                )
            )
        }
        return Path(
            AvatarShapeGenerator.morphedPath(
                shapes: shapes,
                phase: progress,
                in: rect
            )
        )
    }
}
