import WidgetKit
import SwiftUI
import AppIntents

struct LauncherWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Launcher Widget"
    static var description: IntentDescription = .init("Widget that runs shortcuts or opens apps")

    @Parameter(title: "First Action")
    var shortcutOne: SystemShortcut?

    @Parameter(title: "Second Action")
    var shortcutTwo: SystemShortcut?

    @Parameter(title: "Third Action")
    var shortcutThree: SystemShortcut?
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: LauncherWidgetConfigurationIntent())
    }

    func snapshot(for configuration: LauncherWidgetConfigurationIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: LauncherWidgetConfigurationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: LauncherWidgetConfigurationIntent
}

struct HelloWorldWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        if family == .systemSmall {
            VStack(spacing: 8) {
                if let shortcut = entry.configuration.shortcutOne {
                    Button(intent: RunSystemShortcutIntent(shortcut: shortcut)) {
                        Text(shortcut.displayRepresentation.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(white: 0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Unconfigured")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                
                if let shortcut = entry.configuration.shortcutTwo {
                    Button(intent: RunSystemShortcutIntent(shortcut: shortcut)) {
                        Text(shortcut.displayRepresentation.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(white: 0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Unconfigured")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                
                if let shortcut = entry.configuration.shortcutThree {
                    Button(intent: RunSystemShortcutIntent(shortcut: shortcut)) {
                        Text(shortcut.displayRepresentation.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(white: 0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Unconfigured")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .containerBackground(for: .widget) {
                Color.black
            }
        } else {
            VStack {
                Text(widgetGreeting)
                    .font(.headline)
                Text(entry.date, style: .time)
                    .font(.subheadline)
            }
            .containerBackground(for: .widget) {
                Color.blue.opacity(0.3)
            }
        }
    }
    
    var widgetGreeting: String {
        switch family {
        case .systemMedium: return "Hello Medium Widget"
        case .systemLarge: return "Hello Large Widget"
        case .systemExtraLarge: return "Hello Giant Widget"
        case .accessoryCircular: return "Hello Circular"
        case .accessoryRectangular: return "Hello Rect"
        case .accessoryInline: return "Hello Inline"
        default: return "Hello Widget"
        }
    }
}

@main
struct HelloWorldWidget: Widget {
    let kind: String = "HelloWorldWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: LauncherWidgetConfigurationIntent.self, provider: Provider()) { entry in
            HelloWorldWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Launcher Widget")
        .description("A customizable 3-button launcher.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
