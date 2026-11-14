import Testing
import Foundation
import CoreGraphics
import SwiftUI
import MaterialMacLibrary

// MARK: - Glass surfaces

@Suite
struct GlassSurfaceTests {

    @Test
    func testVisualEffectBlurConfiguration() {
        let blur = VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow, blurEnabled: true)
        #expect(blur.material == .hudWindow)
        #expect(blur.blendingMode == .behindWindow)
        #expect(blur.blurEnabled)

        let disabled = VisualEffectBlur(blurEnabled: false)
        #expect(!disabled.blurEnabled)
        #expect(disabled.material == .popover)
    }

    @Test
    func testGlassSurfaceBackgroundConfiguration() {
        let bg = GlassSurfaceBackground(
            cornerRadius: 18,
            surfaceOpacity: 0.5,
            blurEnabled: false,
            tintColor: .red,
            fallbackColor: .blue
        )
        #expect(bg.cornerRadius == 18)
        #expect(bg.surfaceOpacity == 0.5)
        #expect(!bg.blurEnabled)
        #expect(bg.tintColor == .red)
        #expect(bg.fallbackColor == .blue)

        let defaults = GlassSurfaceBackground()
        #expect(defaults.cornerRadius == nil)
        #expect(defaults.surfaceOpacity == nil)
        #expect(defaults.blurEnabled)
        #expect(defaults.tintColor == nil)
        #expect(defaults.fallbackColor == nil)
    }
}

// MARK: - Segmented pill modifier

@Suite
struct SegmentedPillModifierTests {

    @Test
    func testModifierConfiguration() {
        let m = SegmentedPillModifier(role: .first, isVertical: true, radius: 20)
        #expect(m.role == .first)
        #expect(m.isVertical)
        #expect(m.radius == 20)

        let solo = SegmentedPillModifier(role: .solo)
        #expect(solo.role == .solo)
        #expect(!solo.isVertical)
        #expect(solo.radius == 14)
    }

    @Test
    func testViewExtensionApplies() {
        // Compile-level: the modifier must apply to any View.
        let _ = Text("segment").m3SegmentedPill(role: .middle)
        let _ = Text("segment").m3SegmentedPill(role: .last, isVertical: true, radius: 10)
    }
}

// MARK: - Squiggly progress bar

@Suite
struct SquigglyProgressBarTests {

    @Test
    func testProgressClamping() {
        #expect(SquigglyProgressBar.clamped(-0.5) == 0.0)
        #expect(SquigglyProgressBar.clamped(0.0) == 0.0)
        #expect(SquigglyProgressBar.clamped(0.4) == 0.4)
        #expect(SquigglyProgressBar.clamped(1.0) == 1.0)
        #expect(SquigglyProgressBar.clamped(1.5) == 1.0)
    }

    @Test
    func testInstanceClamping() {
        let over = SquigglyProgressBar(progress: 2.0)
        #expect(over.clampedProgress == 1.0)
        #expect(over.progress == 1.0) // clamped on init

        let under = SquigglyProgressBar(progress: -1.0, isPlaying: false)
        #expect(under.clampedProgress == 0.0)

        let mid = SquigglyProgressBar(progress: 0.25, activeColor: .red, trackColor: .gray)
        #expect(mid.clampedProgress == 0.25)
        #expect(mid.activeColor == .red)
        #expect(mid.trackColor == .gray)
        #expect(mid.amplitude == 2.2)
        #expect(mid.waveLength == 18.0)
    }
}

// MARK: - Settings components

@Suite
struct MaterialSettingsComponentsTests {

    @Test
    func testSettingsCardInstantiation() {
        let card = MaterialSettingsCard(icon: "gear", title: "General", subtitle: "Sub") {
            Text("content")
        }
        #expect(card.icon == "gear")
        #expect(card.title == "General")
        #expect(card.subtitle == "Sub")
        #expect(card.palette == nil) // falls back to environment theme

        let withPalette = MaterialSettingsCard(title: "T", palette: .defaultLight) { Text("x") }
        #expect(withPalette.palette == .defaultLight)
    }

    @Test
    func testSegmentedControlInstantiation() {
        let control = MaterialSegmentedControl(
            options: [("Left", 0), ("Right", 1)],
            selection: .constant(0)
        )
        #expect(control.options.count == 2)
        #expect(control.selection == 0)
        #expect(control.palette == nil)
    }

    @Test
    func testSliderRowInstantiation() {
        let row = MaterialSliderRow(
            title: "Opacity",
            valueFormatted: "80%",
            value: .constant(0.8),
            range: 0...1,
            step: 0.05,
            helper: "helper text"
        )
        #expect(row.title == "Opacity")
        #expect(row.valueFormatted == "80%")
        #expect(row.value == 0.8)
        #expect(row.range == 0...1)
        #expect(row.step == 0.05)
        #expect(row.helper == "helper text")
    }

    @Test
    func testToggleRowInstantiation() {
        let row = MaterialToggleRow(title: "Enabled", subtitle: "desc", isOn: .constant(true))
        #expect(row.title == "Enabled")
        #expect(row.subtitle == "desc")
        #expect(row.isOn == true)
    }
}

// MARK: - Control components

@Suite
struct MaterialControlsTests {

    @Test
    func testHeaderActionButton() {
        var tapped = false
        let button = MaterialHeaderActionButton(icon: "plus") { tapped = true }
        #expect(button.icon == "plus")
        button.action()
        #expect(tapped)
    }

    @Test
    func testPillSliderClamping() {
        let over = MaterialPillSlider(icon: "speaker.wave.2", value: 1.7, onIconTap: {}, onValueChanged: { _ in })
        #expect(over.clampedValue == 1.0)

        let under = MaterialPillSlider(icon: "speaker.wave.2", value: -0.3, onIconTap: {}, onValueChanged: { _ in })
        #expect(under.clampedValue == 0.0)

        let mid = MaterialPillSlider(icon: "sun.max", value: 0.5, onIconTap: {}, onValueChanged: { _ in })
        #expect(mid.clampedValue == 0.5)
    }

    @Test
    func testTileInstantiation() {
        let tile = MaterialTile(
            icon: "wifi",
            title: "Wi-Fi",
            subtitle: "DankNet",
            isActive: true,
            hasDetail: true,
            onTap: {},
            onDetailTap: {}
        )
        #expect(tile.icon == "wifi")
        #expect(tile.title == "Wi-Fi")
        #expect(tile.subtitle == "DankNet")
        #expect(tile.isActive)
        #expect(tile.hasDetail)
        #expect(tile.isPillIcon)
    }

    @Test
    func testDetailPageInstantiation() {
        let page = MaterialDetailPage(title: "Bluetooth", onBack: {}, onClose: {}) {
            Text("detail")
        }
        #expect(page.title == "Bluetooth")
    }

    @Test
    func testQuickTilesGrid() {
        let items = [
            MaterialQuickTileItem(icon: "moon.fill", label: "Dark", isActive: true, onTap: {}),
            MaterialQuickTileItem(icon: "sun.and.horizon.fill", label: "Night", onTap: {}),
        ]
        #expect(items[0].id == "moon.fill:Dark") // default id from icon+label
        #expect(items[1].id == "sun.and.horizon.fill:Night")
        #expect(!items[1].isActive)

        let grid = MaterialQuickTilesGrid(items: items)
        #expect(grid.items.count == 2)
    }

    @Test
    func testFloatingEditChrome() {
        #expect(MaterialEditChromeStyle.allCases.count == 2)

        let bar = MaterialFloatingEditChrome(
            title: "Edit Tiles",
            addTitle: "Add Tile",
            onAdd: {},
            onReset: {},
            onDone: {},
            style: .bar
        )
        #expect(bar.title == "Edit Tiles")
        #expect(bar.addTitle == "Add Tile")
        #expect(bar.onReset != nil)
        #expect(bar.style == .bar)

        let capsule = MaterialFloatingEditChrome(onAdd: {}, onDone: {}, style: .capsule)
        #expect(capsule.title == nil)
        #expect(capsule.onReset == nil)
        #expect(capsule.style == .capsule)
    }

    @Test
    func testHoverBounceMath() {
        #expect(HoverBounceModifier.direction(for: 0) == 1.0)   // top
        #expect(HoverBounceModifier.direction(for: 1) == -1.0)  // bottom
        #expect(HoverBounceModifier.direction(for: 2) == 1.0)   // left
        #expect(HoverBounceModifier.direction(for: 3) == -1.0)  // right

        #expect(!HoverBounceModifier.isVerticalDock(position: 0))
        #expect(!HoverBounceModifier.isVerticalDock(position: 1))
        #expect(HoverBounceModifier.isVerticalDock(position: 2))
        #expect(HoverBounceModifier.isVerticalDock(position: 3))

        #expect(HoverBounceModifier.peakOffset == 2.5)
        #expect(HoverBounceModifier.restOffset == 2.0)

        let m = HoverBounceModifier(isHovered: true, position: 1, enabled: false)
        #expect(m.isHovered)
        #expect(m.position == 1)
        #expect(!m.enabled)

        let _ = Text("icon").materialHoverBounce(isHovered: true, position: 0)
    }
}

// MARK: - Popout layout & animation math

@Suite
struct PopoutLayoutHelperTests {

    private let fullFrame = CGRect(x: 0, y: 0, width: 1440, height: 900)
    private let visibleFrame = CGRect(x: 0, y: 23, width: 1440, height: 877)

    private func input(
        bodyWidth: CGFloat = 300,
        bodyHeight: CGFloat = 200,
        anchorX: CGFloat? = 720,
        barPosition: String = "top",
        connected: Bool = false,
        filletRadius: CGFloat = 14,
        barFrame: CGRect = CGRect(x: 0, y: 858, width: 1440, height: 42),
        mouse: CGPoint = CGPoint(x: 720, y: 400)
    ) -> PopoutLayoutInput {
        PopoutLayoutInput(
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            anchorX: anchorX,
            barPosition: barPosition,
            connected: connected,
            filletRadius: filletRadius,
            barFrame: barFrame,
            visibleFrame: visibleFrame,
            fullFrame: fullFrame,
            mouseLocation: mouse
        )
    }

    @Test
    func testGap() {
        #expect(PopoutLayoutHelper.gap(connected: true) == 0.0)
        #expect(PopoutLayoutHelper.gap(connected: false) == 8.0)
    }

    @Test
    func testTotalSize() {
        // Disconnected: body size unchanged
        let plain = PopoutLayoutHelper.totalSize(for: input(connected: false))
        #expect(plain == CGSize(width: 300, height: 200))

        // Connected horizontal bar: width grows by 2 fillets
        let connectedH = PopoutLayoutHelper.totalSize(for: input(connected: true, filletRadius: 14))
        #expect(connectedH == CGSize(width: 328, height: 200))

        // Connected vertical bar: height grows by 2 fillets
        let connectedV = PopoutLayoutHelper.totalSize(for: input(barPosition: "left", connected: true, filletRadius: 10))
        #expect(connectedV == CGSize(width: 300, height: 220))
    }

    @Test
    func testTopBarFrameDisconnected() {
        let f = PopoutLayoutHelper.frame(for: input(barPosition: "top", connected: false))
        // x centered on anchorX: 720 - 150 = 570
        #expect(f.minX == 570)
        #expect(f.width == 300 && f.height == 200)
        // y: barBottom(858) - height(200) - gap(8) = 650, clamped into visible frame
        #expect(f.minY == 650)
    }

    @Test
    func testTopBarFrameConnected() {
        let f = PopoutLayoutHelper.frame(for: input(barPosition: "top", connected: true, filletRadius: 14))
        // total width 328; x = 720 - 150 - 14 = 556
        #expect(f.minX == 556)
        #expect(f.width == 328)
        // flush: y = barBottom - totalHeight = 858 - 200 = 658
        #expect(f.minY == 658)
    }

    @Test
    func testBottomBarFrame() {
        let bottomBar = CGRect(x: 0, y: 0, width: 1440, height: 42)
        let f = PopoutLayoutHelper.frame(for: input(barPosition: "bottom", connected: false, barFrame: bottomBar))
        // y = min(visibleMaxY(900) - 200 - 8, barTop(42) + 8) = 50
        #expect(f.minY == 50)
        #expect(f.minX == 570)

        let fc = PopoutLayoutHelper.frame(for: input(barPosition: "bottom", connected: true, filletRadius: 14, barFrame: bottomBar))
        // flush: y = barTop = 42; x = 720 - 150 - 14 = 556, width 328
        #expect(fc.minY == 42)
        #expect(fc.minX == 556)
        #expect(fc.width == 328)
    }

    @Test
    func testLeftBarFrame() {
        let leftBar = CGRect(x: 0, y: 0, width: 56, height: 900)
        let f = PopoutLayoutHelper.frame(for: input(
            barPosition: "left",
            connected: false,
            barFrame: leftBar,
            mouse: CGPoint(x: 100, y: 400)
        ))
        // x = barRight(56) + gap(8) = 64
        #expect(f.minX == 64)
        // y = 400 - 100 = 300
        #expect(f.minY == 300)
        #expect(f.width == 300 && f.height == 200)
    }

    @Test
    func testRightBarFrameClampsToVisible() {
        let rightBar = CGRect(x: 1384, y: 0, width: 56, height: 900)
        let f = PopoutLayoutHelper.frame(for: input(
            barPosition: "right",
            connected: false,
            barFrame: rightBar,
            mouse: CGPoint(x: 1400, y: 890) // near bottom-right corner
        ))
        // x = barLeft(1384) - 300 - 8 = 1076
        #expect(f.minX == 1076)
        // y clamped to visibleFrame.maxY - height - 12 = 900 - 200 - 12 = 688
        #expect(f.minY == 688)
    }

    @Test
    func testAnchorXClampedIntoVisibleFrame() {
        let f = PopoutLayoutHelper.frame(for: input(anchorX: 5, barPosition: "top", connected: false))
        // 5 - 150 = -145 clamped to visibleFrame.minX + 8 = 8
        #expect(f.minX == 8)
    }

    @Test
    func testControlCenterFrame() {
        let i = input(barPosition: "top", connected: false)
        var cc = i
        cc.isControlCenter = true
        cc.marginX = 8
        let f = PopoutLayoutHelper.frame(for: cc)
        // x = fullFrame.maxX(1440) - 300 - 8 = 1132, within visible bounds
        #expect(f.minX == 1132)
        // top bar, not connected: y = barBottom(858) - 200 - 8 = 650
        #expect(f.minY == 650)
    }

    @Test
    func testAnchorToControlCenter() {
        var i = input(barPosition: "top", connected: false)
        i.anchorToControlCenter = true
        i.controlCenterFrame = CGRect(x: 1000, y: 400, width: 360, height: 500)
        let f = PopoutLayoutHelper.frame(for: i)
        #expect(f.minX == 1000)
        // top: y = ccFrame.maxY(900) - 200 = 700
        #expect(f.minY == 700)
    }
}

@Suite
struct PopoutAnimationHelperTests {

    @Test
    func testDurationsAndCurves() {
        #expect(PopoutAnimationHelper.entranceDuration == 0.250)
        #expect(PopoutAnimationHelper.exitDuration == 0.180)
        #expect(PopoutAnimationHelper.entranceCurve == .emphasizedDecel)
        #expect(PopoutAnimationHelper.exitCurve == .emphasizedAccel)
        // emphasizedDecel resolves to (1.0, 1.0) terminal control point
        #expect(PopoutAnimationHelper.entranceCurve.c2y == 1.0)
        #expect(PopoutAnimationHelper.exitCurve.c2y == 0.15)
    }

    @Test
    func testScaleAndOpacity() {
        let presentedH = PopoutAnimationHelper.scale(isVerticalBar: false, presented: true)
        #expect(presentedH == CGSize(width: 1.0, height: 1.0))

        let hiddenH = PopoutAnimationHelper.scale(isVerticalBar: false, presented: false)
        #expect(hiddenH.width == 0.94)
        #expect(hiddenH.height == 0.05)

        let hiddenV = PopoutAnimationHelper.scale(isVerticalBar: true, presented: false)
        #expect(hiddenV.width == 0.05)
        #expect(hiddenV.height == 0.94)

        #expect(PopoutAnimationHelper.opacity(presented: true) == 1.0)
        #expect(PopoutAnimationHelper.opacity(presented: false) == 0.0)
    }

    @Test
    func testCollapsedSize() {
        let total = CGSize(width: 328, height: 200)
        #expect(PopoutAnimationHelper.collapsedSize(isVerticalBar: false, total: total, presented: true) == total)
        #expect(PopoutAnimationHelper.collapsedSize(isVerticalBar: false, total: total, presented: false) == CGSize(width: 328, height: 0))
        #expect(PopoutAnimationHelper.collapsedSize(isVerticalBar: true, total: total, presented: false) == CGSize(width: 0, height: 200))
    }

    @Test
    func testAnimationsConstruct() {
        let _ = PopoutAnimationHelper.entranceAnimation()
        let _ = PopoutAnimationHelper.exitAnimation(duration: 0.1)
    }
}

// MARK: - Popout container

@Suite
struct MaterialPopoutContainerTests {

    @Test
    func testContainerConfiguration() {
        var dismissed = false
        var hover: Bool? = nil
        let container = MaterialPopoutSurfaceContainer(
            bodyWidth: 300,
            bodyHeight: 200,
            cornerRadius: 18,
            edge: .top,
            connected: true,
            filletRadius: 14,
            blurEnabled: true,
            surfaceOpacity: 0.9,
            onDismiss: { dismissed = true },
            onHoverChange: { hover = $0 }
        ) {
            Text("popout")
        }
        #expect(container.bodyWidth == 300)
        #expect(container.bodyHeight == 200)
        #expect(container.cornerRadius == 18)
        #expect(container.edge == .top)
        #expect(container.connected)
        #expect(container.filletRadius == 14)
        #expect(container.blurEnabled)
        #expect(container.surfaceOpacity == 0.9)
        container.onDismiss?()
        #expect(dismissed)
        container.onHoverChange?(true)
        #expect(hover == true)
    }

    @Test
    func testFilletRadiusClamped() {
        let c = MaterialPopoutSurfaceContainer(bodyWidth: 100, bodyHeight: 100, filletRadius: 1) { Text("x") }
        #expect(c.filletRadius == 4.0) // clamped to minimum
    }
}

// MARK: - Feedback views

@Suite
struct MaterialFeedbackViewsTests {

    @Test
    func testToastCard() {
        let toast = MaterialToastCard(icon: "checkmark.circle", message: "Done")
        #expect(toast.icon == "checkmark.circle")
        #expect(toast.message == "Done")
        #expect(toast.blurEnabled)
    }

    @Test
    func testOSDPillGaugeClamping() {
        let gauge = MaterialOSDPill(icon: "speaker.wave.3", value: 1.4, formattedValue: "140%")
        #expect(gauge.clampedValue == 1.0)
        #expect(gauge.value == 1.0) // clamped on init

        let under = MaterialOSDPill(icon: "speaker.wave.3", value: -0.2, formattedValue: "-20%")
        #expect(under.clampedValue == 0.0)

        let text = MaterialOSDPill(icon: "moon", title: "Focus", formattedValue: "On")
        #expect(text.clampedValue == nil)
        #expect(text.title == "Focus")
        #expect(text.width == 260)
    }

    @Test
    func testActionTile() {
        var tapped = false
        let tile = MaterialActionTile(icon: "power", label: "Shut Down", color: .red) { tapped = true }
        #expect(tile.icon == "power")
        #expect(tile.label == "Shut Down")
        #expect(tile.color == .red)
        tile.action()
        #expect(tapped)

        let defaultColor = MaterialActionTile(icon: "lock", label: "Lock") {}
        #expect(defaultColor.color == .accentColor)
    }
}

// MARK: - Theme propagation

@Suite
struct MaterialThemePropagationTests {

    @Test
    @MainActor
    func testEnvironmentKeyDefault() {
        let key = MaterialThemeEnvironmentKey.defaultValue
        #expect(key.palette.isDark) // default theme is dark
    }

    @Test
    @MainActor
    func testThemeInjectionModifier() {
        let theme = MaterialTheme(palette: .defaultLight, activeThemeName: "light-test")
        #expect(!theme.palette.isDark)
        #expect(theme.activeThemeName == "light-test")
        // Compile-level: the environment modifier must apply to any View.
        let _ = Text("themed").materialTheme(theme)
    }

    @Test
    @MainActor
    func testThemeHelpersUsedByComponents() {
        let theme = MaterialTheme(palette: .defaultDark)
        // Colors the components resolve from the environment theme
        #expect(theme.subtleTrackColor != .clear)
        #expect(theme.panelBorderColor != .clear)
        #expect(theme.primary == MaterialPalette.defaultDark.primary.swiftUIColor)
        #expect(theme.surfaceContainerHigh == MaterialPalette.defaultDark.surfaceContainerHigh.swiftUIColor)
        #expect(theme.cornerRadius(base: 14) == 14)
        theme.shapeTokens = MaterialShapeTokens(strength: 100)
        #expect(theme.cornerRadius(base: 14) == 28)
    }
}
