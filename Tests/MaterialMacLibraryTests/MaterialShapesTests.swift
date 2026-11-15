import Testing
import Foundation
import CoreGraphics
import SwiftUI
import MaterialMacLibrary

@Suite
struct MaterialShapesTests {

    private let avatarRect = CGRect(x: 0, y: 0, width: 64, height: 64)

    private func expectFiniteNonEmpty(_ path: CGPath, source: String) {
        #expect(!path.isEmpty, "\(source) path is empty")
        let bounds = path.boundingBox
        #expect(bounds.width.isFinite && bounds.height.isFinite, "\(source) bounds not finite")
        #expect(bounds.width > 0 && bounds.height > 0, "\(source) bounds degenerate: \(bounds)")
    }

    // MARK: - Avatar shapes (all 12)

    @Test
    func testAvatarShapeGeneratorAllShapes() {
        #expect(AvatarShapeGenerator.allShapeNames.count == 12)
        for shapeName in AvatarShapeGenerator.allShapeNames {
            let path = AvatarShapeGenerator.path(for: shapeName, in: avatarRect)
            expectFiniteNonEmpty(path, source: "avatar:\(shapeName)")
        }
        // Unknown shape falls back to circle
        let fallback = AvatarShapeGenerator.path(for: "does-not-exist", in: avatarRect)
        expectFiniteNonEmpty(fallback, source: "avatar:fallback")
    }

    // MARK: - M3 Expressive 35 Shapes & Morphing

    @Test
    func testAll35MaterialExpressiveShapes() {
        #expect(MaterialExpressiveShape.allCases.count == 35)
        #expect(AvatarShapeGenerator.expressiveShapeNames.count == 35)
        for shape in MaterialExpressiveShape.allCases {
            let path = AvatarShapeGenerator.path(for: shape, in: avatarRect)
            expectFiniteNonEmpty(path, source: "expressive:\(shape.rawValue)")
            // Also verify Compose name resolution (e.g. "Cookie4Sided", "Clover8Leaf", "VerySunny")
            let resolved = MaterialExpressiveShape.resolve(shape.composeName)
            #expect(resolved == shape, "composeName \(shape.composeName) did not resolve to \(shape.rawValue)")
            let geo = GeometricAvatarShape(shape: shape)
            #expect(!geo.path(in: avatarRect).isEmpty)
        }
    }

    @Test
    func testMaterialMorphingShapeAndMorphedPaths() {
        let pairs: [(MaterialExpressiveShape, MaterialExpressiveShape)] = [
            (.circle, .square),
            (.softBurst, .cookie9),
            (.pentagon, .pill),
            (.sunny, .heart),
            (.clover4, .puffyDiamond)
        ]
        for (from, to) in pairs {
            for progress: CGFloat in [0.0, 0.25, 0.5, 0.75, 1.0] {
                let cgPath = AvatarShapeGenerator.morphedPath(from: from, to: to, progress: progress, in: avatarRect)
                expectFiniteNonEmpty(cgPath, source: "morph:\(from.rawValue)->\(to.rawValue)@\(progress)")
                var morphShape = MaterialMorphingShape(from: from, to: to, progress: 0)
                morphShape.animatableData = progress
                #expect(morphShape.progress == progress)
                let swiftUIPath = morphShape.path(in: avatarRect)
                #expect(!swiftUIPath.isEmpty)
            }
        }

        // Multi-shape loading indicator cycle morph
        let cycle = AvatarShapeGenerator.loadingIndicatorCycle
        #expect(cycle.count == 7)
        for phase: CGFloat in [0.0, 1.3, 3.7, 6.9] {
            let cycleShape = MaterialMorphingShape(shapes: cycle, progress: phase)
            let p = cycleShape.path(in: avatarRect)
            #expect(!p.isEmpty)
            #expect(p.boundingRect.width > 0 && p.boundingRect.height > 0)
        }
    }

    @Test
    func testGeometricAvatarShape() {
        for shapeName in AvatarShapeGenerator.allShapeNames {
            let shape = GeometricAvatarShape(shapeName: shapeName)
            let path = shape.path(in: avatarRect)
            #expect(!path.isEmpty, "GeometricAvatarShape \(shapeName) empty")
            let bounds = path.boundingRect
            #expect(bounds.width.isFinite && bounds.height.isFinite)
            #expect(bounds.width > 0 && bounds.height > 0)
        }
    }

    // MARK: - GothEarCornerShape

    @Test
    func testGothEarCornerShapeAllEdges() {
        let rect = CGRect(x: 0, y: 0, width: 320, height: 48)
        for edge in MaterialEdge.allCases {
            let shape = GothEarCornerShape(
                edge: edge,
                cornerStyle: .gothic,
                cornerRadius: -1,
                filletRadius: 14
            )
            let path = shape.path(in: rect)
            #expect(!path.isEmpty, "gothic \(edge.rawValue) empty")
            let bounds = path.boundingRect
            #expect(bounds.width.isFinite && bounds.height.isFinite, "gothic \(edge.rawValue) not finite")
            #expect(bounds.width > 0 && bounds.height > 0, "gothic \(edge.rawValue) degenerate")
        }
    }

    @Test
    func testGothEarCornerShapeAllStyles() {
        let rects = [
            CGRect(x: 0, y: 0, width: 320, height: 48),
            CGRect(x: 0, y: 0, width: 48, height: 320),
        ]
        for rect in rects {
            for style in MaterialCornerStyle.allCases {
                for edge in MaterialEdge.allCases {
                    let shape = GothEarCornerShape(
                        edge: edge,
                        cornerStyle: style,
                        cornerRadius: style == .rounded ? 18 : -1,
                        filletRadius: 14,
                        isVertical: rect.height > rect.width
                    )
                    let path = shape.path(in: rect)
                    #expect(!path.isEmpty, "\(style.rawValue)/\(edge.rawValue) empty in \(rect)")
                    let bounds = path.boundingRect
                    #expect(bounds.width.isFinite && bounds.height.isFinite)
                    #expect(bounds.width > 0 && bounds.height > 0)
                }
            }
        }
    }

    @Test
    func testGothEarCornerShapeSquareAndCapsule() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 40)
        let square = GothEarCornerShape(edge: .bottom, cornerStyle: .square).path(in: rect)
        #expect(square.boundingRect == rect)

        let capsule = GothEarCornerShape(edge: .bottom, cornerStyle: .capsule).path(in: rect)
        let capsuleBounds = capsule.boundingRect
        #expect(capsuleBounds.width > 0 && capsuleBounds.height > 0)
        #expect(abs(capsuleBounds.width - rect.width) <= 1e-6)
        #expect(abs(capsuleBounds.height - rect.height) <= 1e-6)
    }

    // MARK: - InvertedCutoutCornerShape

    @Test
    func testInvertedCutoutCornerShape() {
        let rect = CGRect(x: 0, y: 0, width: 160, height: 44)
        for concave in [true, false] {
            let shape = InvertedCutoutCornerShape(
                topLeadingRadius: 18,
                topTrailingRadius: 18,
                bottomTrailingRadius: 12,
                bottomLeadingRadius: 12,
                concaveTopFillets: concave,
                filletRadius: 12
            )
            let path = shape.path(in: rect)
            #expect(!path.isEmpty, "cutout concave=\(concave) empty")
            let bounds = path.boundingRect
            #expect(bounds.width.isFinite && bounds.height.isFinite)
            #expect(bounds.width > 0 && bounds.height > 0)
        }
    }

    // MARK: - SegmentedPillShape

    @Test
    func testSegmentedPillShape() {
        let rect = CGRect(x: 0, y: 0, width: 60, height: 28)
        for role in MaterialSegmentRole.allCases {
            for vertical in [false, true] {
                let shape = SegmentedPillShape(role: role, isVertical: vertical, radius: 14)
                let path = shape.path(in: rect)
                #expect(!path.isEmpty, "pill \(role.rawValue) vertical=\(vertical) empty")
                let bounds = path.boundingRect
                #expect(bounds.width.isFinite && bounds.height.isFinite)
                #expect(bounds.width > 0 && bounds.height > 0)
            }
        }
        // First and last segments are mirror images in horizontal orientation: paths differ
        let first = SegmentedPillShape(role: .first, radius: 14).path(in: rect)
        let last = SegmentedPillShape(role: .last, radius: 14).path(in: rect)
        #expect(first != last)
        // Solo is a full pill
        let solo = SegmentedPillShape(role: .solo, radius: 14).path(in: rect)
        #expect(!solo.isEmpty)
    }

    // MARK: - WavyVisualizerRing

    @Test
    func testWavyVisualizerRing() {
        let rect = CGRect(x: 0, y: 0, width: 64, height: 64)
        let ring = WavyVisualizerRing(harmonics: 8, amplitude: 4.0, phase: 0.0)
        let path = ring.path(in: rect)
        #expect(!path.isEmpty)
        let bounds = path.boundingRect
        #expect(bounds.width.isFinite && bounds.height.isFinite)
        #expect(bounds.width > 0 && bounds.height > 0)
        #expect(bounds.width <= rect.width + 1e-6)
        #expect(bounds.height <= rect.height + 1e-6)

        // Phase animation data roundtrips
        var animated = WavyVisualizerRing()
        animated.animatableData = 1.5
        #expect(animated.phase == 1.5)
    }

    // MARK: - SlantedParallelogramShape

    @Test
    func testSlantedParallelogramShape() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 40)
        for skew: CGFloat in [32, -32, 0, 500] {
            let shape = SlantedParallelogramShape(skew: skew, cornerRadius: 8)
            let path = shape.path(in: rect)
            #expect(!path.isEmpty, "parallelogram skew=\(skew) empty")
            let bounds = path.boundingRect
            #expect(bounds.width.isFinite && bounds.height.isFinite)
            #expect(bounds.width > 0 && bounds.height > 0)
        }

        // Animatable pair roundtrips
        var shape = SlantedParallelogramShape()
        shape.animatableData = AnimatablePair(10, 4)
        #expect(shape.skew == 10)
        #expect(shape.cornerRadius == 4)
    }
}
