import SwiftUI
import WidgetKit

@main
struct LauncherBoardApp: App {
    var body: some Scene {
        WindowGroup {
            GalleryView()
        }
    }
}

/// One screen. Swipe to see a theme, tap to see what a tinted Home Screen
/// does to it, then pick that theme in the widget's own editor.
struct GalleryView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var size: BoardSize = .medium
    @State private var accented = false

    private var slotCount: Int {
        min(size.capacity, BoardSample.names.count)
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Picker("", selection: $size) {
                    ForEach(BoardSize.allCases, id: \.self) { family in
                        Text(family.displayName).tag(family)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Button {
                    accented.toggle()
                } label: {
                    Image(systemName: accented ? "circle.lefthalf.filled" : "circle")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                .foregroundStyle(accented ? Color.accentColor : Color.secondary)
                .accessibilityLabel("Tinted Home Screen")
            }
            .padding(.horizontal, 20)

            TabView {
                ForEach(Theme.allCases, id: \.self) { theme in
                    VStack(spacing: 14) {
                        board(theme)
                        Text(theme.displayName)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.default, value: size)

            Text("Edit Widget · Theme")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 8)
        }
        // A tile shows the shortcut's own name, so a rename in Shortcuts has
        // to reach the widget. The timeline never refreshes on its own, and
        // opening this app is the only moment the product gets to ask.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    private func board(_ theme: Theme) -> some View {
        let names = (0..<slotCount).map { BoardSample.names[$0 % BoardSample.names.count] }
        let grid = BoardGrid.resolve(
            count: slotCount,
            size: size,
            density: .compact,
            longestName: names.map(\.count).max() ?? 0
        )
        return BoardView(grid: grid, count: slotCount) { index in
            SlotFace(
                name: names[index],
                surface: theme.surface(at: index, accented: accented),
                label: theme.labelColor(accented: accented),
                mode: grid.mode,
                font: grid.font
            )
        }
        .frame(width: size.canvas.width, height: size.canvas.height)
        .background { BoardBackground(theme: theme, accented: accented) }
        // A tinted Home Screen platter is dark whatever the app's appearance
        // is, so the stand-in is a fixed color. Color.secondary here would go
        // light in Light mode and invert the very thing this is previewing.
        .background { accented ? Color(.sRGB, red: 0.16, green: 0.18, blue: 0.22) : Color.clear }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        // Ink against a dark page and Paper against a light one are both
        // within about 1.1:1 of the app's own background, so without an edge
        // the card for one theme disappears in each appearance.
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
        }
    }
}

#Preview {
    GalleryView()
}
