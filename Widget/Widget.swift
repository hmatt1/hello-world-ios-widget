import Foundation
import AppIntents
import SwiftUI
import WidgetKit

struct LauncherEntry: TimelineEntry {
    let date: Date
    let configuration: LauncherIntent
    /// Names to draw instead of shortcuts. The gallery card and the redacted
    /// placeholder use it, because neither has a configuration to read.
    let sample: [String]
}

struct LauncherProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> LauncherEntry {
        LauncherEntry(date: Date(), configuration: LauncherIntent(), sample: BoardSample.names)
    }

    func snapshot(for configuration: LauncherIntent, in context: Context) async -> LauncherEntry {
        // The widget gallery asks for a snapshot before anything is configured.
        // Showing the empty state there would sell the widget as a blank card.
        let sample = context.isPreview && configuration.slots.isEmpty ? BoardSample.names : []
        return LauncherEntry(date: Date(), configuration: configuration, sample: sample)
    }

    func timeline(for configuration: LauncherIntent, in context: Context) async -> Timeline<LauncherEntry> {
        // The board only changes when the widget is edited, which reloads the
        // timeline anyway. One entry, never refreshed, spends no budget.
        let entry = LauncherEntry(date: Date(), configuration: configuration, sample: [])
        return Timeline(entries: [entry], policy: .never)
    }
}

extension BoardSize {
    init(family: WidgetFamily) {
        switch family {
        case .systemSmall: self = .small
        case .systemMedium: self = .medium
        default: self = .large
        }
    }
}

struct LauncherWidgetView: View {
    let entry: LauncherEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        let size = BoardSize(family: family)
        // Anything that is not full colour gets the same stripped-back
        // treatment, so a future or Lock Screen mode never falls through.
        let accented = renderingMode != .fullColor
        let slots = entry.configuration.slots
        let sample = entry.sample
        let rawNames = sample.isEmpty
            ? slots.map { String(localized: $0.displayRepresentation.title) }
            : sample
        
        let resolved = BoardGrid.resolve(
            count: rawNames.count,
            size: size,
            density: entry.configuration.density,
            longestName: rawNames.map(\.count).max() ?? 0,
            pattern: entry.configuration.layoutPattern,
            corners: entry.configuration.internalCorners
        )
        
        let grid = resolved.grid
        let names = Array(rawNames.prefix(resolved.visibleSlots))

        Group {
            if names.isEmpty {
                BoardEmptyState(theme: entry.configuration.theme, accented: accented)
            } else {
                BoardView(grid: grid, count: names.count) { index in
                    if sample.isEmpty {
                        Button(intent: RunSystemShortcutIntent(shortcut: slots[index])) {
                            face(name: names[index], index: index, grid: grid, accented: accented)
                        }
                        .buttonStyle(.plain)
                    } else {
                        face(name: names[index], index: index, grid: grid, accented: accented)
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            BoardBackground(theme: entry.configuration.theme, accented: accented)
        }
    }

    private func face(name: String, index: Int, grid: BoardGrid, accented: Bool) -> SlotFace {
        let theme = entry.configuration.theme
        return SlotFace(
            name: name,
            surface: theme.surface(at: index, accented: accented),
            label: theme.labelColor(accented: accented),
            mode: grid.mode,
            font: grid.font,
            cornerRadius: grid.cornerRadius
        )
    }
}

@main
struct LauncherBoardWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "LauncherBoard",
            intent: LauncherIntent.self,
            provider: LauncherProvider()
        ) { entry in
            LauncherWidgetView(entry: entry)
        }
        .configurationDisplayName("Launcher Board")
        .description("Run your shortcuts from the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
