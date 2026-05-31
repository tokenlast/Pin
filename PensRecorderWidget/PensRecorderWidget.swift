import SwiftUI
import WidgetKit

private let toggleURL = URL(string: "pin://toggle")!

struct PensRecorderEntry: TimelineEntry {
    let date: Date
}

struct PensRecorderProvider: TimelineProvider {
    func placeholder(in context: Context) -> PensRecorderEntry {
        PensRecorderEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (PensRecorderEntry) -> Void) {
        completion(PensRecorderEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PensRecorderEntry>) -> Void) {
        completion(Timeline(entries: [PensRecorderEntry(date: Date())], policy: .never))
    }
}

struct PensRecorderWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PensRecorderEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                circularLockScreenView
            case .accessoryRectangular:
                rectangularLockScreenView
            case .accessoryInline:
                Text("📌 Pin")
            default:
                homeScreenView
            }
        }
        .containerBackground(.background, for: .widget)
        .widgetURL(toggleURL)
    }

    private var homeScreenView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📌")
                .font(.system(size: 34))

            Spacer(minLength: 0)

            Text("Pin")
                .font(.headline.weight(.bold))

            Text("Tap to record or stop")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var circularLockScreenView: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text("📌")
                .font(.system(size: 28))
                .minimumScaleFactor(0.7)
        }
    }

    private var rectangularLockScreenView: some View {
        HStack(spacing: 6) {
            Text("📌")
                .font(.title3)

            VStack(alignment: .leading, spacing: 1) {
                Text("Pin")
                    .font(.headline)
                Text("Tap to record")
                    .font(.caption2)
            }
        }
    }
}

struct PensRecorderWidget: Widget {
    let kind = "PensRecorderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PensRecorderProvider()) { entry in
            PensRecorderWidgetView(entry: entry)
        }
        .configurationDisplayName("Pin")
        .description("Tap the pin to start or stop recording.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
