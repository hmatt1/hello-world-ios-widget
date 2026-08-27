import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct HelloWorldWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
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
    
    var widgetGreeting: String {
        switch family {
        case .systemSmall: return "Hello Small Widget"
        case .systemMedium: return "Hello Medium Widget"
        case .systemLarge: return "Hello Large Widget"
        case .systemExtraLarge: return "Hello Giant Widget"
        case .accessoryCircular: return "Hello Circular"
        case .accessoryRectangular: return "Hello Rect"
        case .accessoryInline: return "Hello Inline"
        @unknown default: return "Hello Widget"
        }
    }
}

@main
struct HelloWorldWidget: Widget {
    let kind: String = "HelloWorldWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HelloWorldWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hello World Widget")
        .description("This is a simple hello world widget.")
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
