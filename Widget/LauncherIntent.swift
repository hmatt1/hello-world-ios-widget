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
            .compact: DisplayRepresentation(title: "Compact"),
            .roomy: DisplayRepresentation(title: "Roomy")
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

    @Parameter(title: "Theme", default: .midnight)
    var theme: Theme

    @Parameter(title: "Density", default: .compact)
    var density: Density

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
