import Foundation
import AppIntents

extension Theme: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Theme")
    }

    /// Spelled out rather than derived from `displayName`. AppIntents lifts
    /// these at build time and its extractor only reads literal dictionaries,
    /// so a computed one risks the picker showing raw case names on device.
    static var caseDisplayRepresentations: [Theme: DisplayRepresentation] {
        [
            .ink: DisplayRepresentation(title: "Ink"),
            .paper: DisplayRepresentation(title: "Paper"),
            .midnight: DisplayRepresentation(title: "Midnight"),
            .aurora: DisplayRepresentation(title: "Aurora"),
            .sunset: DisplayRepresentation(title: "Sunset")
        ]
    }
}

extension Density: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Density")
    }

    static var caseDisplayRepresentations: [Density: DisplayRepresentation] {
        [
            .edge: DisplayRepresentation(title: "Edge"),
            .tight: DisplayRepresentation(title: "Tight"),
            .snug: DisplayRepresentation(title: "Snug"),
            .compact: DisplayRepresentation(title: "Compact"),
            .balanced: DisplayRepresentation(title: "Balanced"),
            .airy: DisplayRepresentation(title: "Airy"),
            .roomy: DisplayRepresentation(title: "Roomy"),
            .spacious: DisplayRepresentation(title: "Spacious"),
            .open: DisplayRepresentation(title: "Open"),
            .floating: DisplayRepresentation(title: "Floating")
        ]
    }
}

extension LayoutPattern: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Layout Pattern")
    }

    static var caseDisplayRepresentations: [LayoutPattern: DisplayRepresentation] {
        [
            .auto: DisplayRepresentation(title: "Auto (Best Fit)"),
            .singleHero: DisplayRepresentation(title: "Single Hero"),
            .verticalStack: DisplayRepresentation(title: "Vertical Stack"),
            .horizontalStack: DisplayRepresentation(title: "Horizontal Stack"),
            .gridMatrix: DisplayRepresentation(title: "Grid Matrix"),
            .horizontalStrip: DisplayRepresentation(title: "Horizontal Strip"),
            .verticalList: DisplayRepresentation(title: "Vertical List"),
            .dualColumnGrid: DisplayRepresentation(title: "Dual Column Grid")
        ]
    }
}

extension InternalCorners: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Internal Corners")
    }

    static var caseDisplayRepresentations: [InternalCorners: DisplayRepresentation] {
        [
            .rounded: DisplayRepresentation(title: "Rounded"),
            .square: DisplayRepresentation(title: "Square"),
            .sharp: DisplayRepresentation(title: "Sharp")
        ]
    }
}

extension BackgroundStyle: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Background Style")
    }

    static var caseDisplayRepresentations: [BackgroundStyle: DisplayRepresentation] {
        [
            .theme: DisplayRepresentation(title: "Theme (Solid)"),
            .liquidGlass: DisplayRepresentation(title: "Liquid Glass"),
            .transparent: DisplayRepresentation(title: "Transparent")
        ]
    }
}

extension WidgetPosition: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Widget Position")
    }

    static var caseDisplayRepresentations: [WidgetPosition: DisplayRepresentation] {
        [
            .topLeft: DisplayRepresentation(title: "Top Left"),
            .topRight: DisplayRepresentation(title: "Top Right"),
            .middleLeft: DisplayRepresentation(title: "Middle Left"),
            .middleRight: DisplayRepresentation(title: "Middle Right"),
            .bottomLeft: DisplayRepresentation(title: "Bottom Left"),
            .bottomRight: DisplayRepresentation(title: "Bottom Right"),
            .top: DisplayRepresentation(title: "Top"),
            .middle: DisplayRepresentation(title: "Middle"),
            .bottom: DisplayRepresentation(title: "Bottom")
        ]
    }
}

/// Fourteen rows: twelve shortcuts and two looks. The number of assigned
/// shortcuts is the slot count, so no control can contradict another.
struct LauncherIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Launcher Board"

    static var description: IntentDescription {
        IntentDescription("Run your shortcuts from the Home Screen.")
    }

    @Parameter(title: "1")
    var shortcut1: SystemShortcut?

    @Parameter(title: "2")
    var shortcut2: SystemShortcut?

    @Parameter(title: "3")
    var shortcut3: SystemShortcut?

    @Parameter(title: "4")
    var shortcut4: SystemShortcut?

    @Parameter(title: "5")
    var shortcut5: SystemShortcut?

    @Parameter(title: "6")
    var shortcut6: SystemShortcut?

    @Parameter(title: "7")
    var shortcut7: SystemShortcut?

    @Parameter(title: "8")
    var shortcut8: SystemShortcut?

    @Parameter(title: "9")
    var shortcut9: SystemShortcut?

    @Parameter(title: "10")
    var shortcut10: SystemShortcut?

    @Parameter(title: "11")
    var shortcut11: SystemShortcut?

    @Parameter(title: "12")
    var shortcut12: SystemShortcut?

    @Parameter(title: "Layout Pattern", default: .auto)
    var layoutPattern: LayoutPattern

    @Parameter(title: "Theme", default: .midnight)
    var theme: Theme

    @Parameter(title: "Density", default: .compact)
    var density: Density

    @Parameter(title: "Internal Corners", default: .rounded)
    var internalCorners: InternalCorners
    
    @Parameter(title: "Background", default: .theme)
    var backgroundStyle: BackgroundStyle
    
    @Parameter(title: "Position (If Transparent)", default: .topLeft)
    var widgetPosition: WidgetPosition

    /// Assigned shortcuts in slot order, holes closed.
    var slots: [SystemShortcut] {
        let all: [SystemShortcut?] = [
            shortcut1,
            shortcut2,
            shortcut3,
            shortcut4,
            shortcut5,
            shortcut6,
            shortcut7,
            shortcut8,
            shortcut9,
            shortcut10,
            shortcut11,
            shortcut12
        ]
        return all.compactMap { $0 }
    }
}
