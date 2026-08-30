import SwiftUI
import WidgetKit

@main
struct LauncherBoardApp: App {
    var body: some Scene {
        WindowGroup {
            ControlPaneView()
        }
    }
}

/// The interactive control pane for previewing widget designs and layout behaviors.
struct ControlPaneView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var size: BoardSize = .medium
    @State private var slots: Int = 4
    @State private var pattern: LayoutPattern = .auto
    @State private var theme: Theme = .midnight
    @State private var density: Density = .compact
    @State private var corners: InternalCorners = .rounded

    /// Valid patterns change based on the selected widget family.
    var validPatterns: [LayoutPattern] {
        switch size {
        case .small:
            return [.auto, .singleHero, .verticalStack, .horizontalStack, .gridMatrix]
        case .medium:
            return [.auto, .singleHero, .horizontalStrip, .verticalList, .dualColumnGrid]
        case .large:
            return [.auto, .gridMatrix, .verticalStack]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Static Preview Window
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                board(theme)
                    .animation(.default, value: size)
                    .animation(.default, value: slots)
                    .animation(.default, value: pattern)
                    .animation(.default, value: theme)
                    .animation(.default, value: density)
                    .animation(.default, value: corners)
            }
            .frame(height: 360)
            
            // Control Pane
            Form {
                Section(header: Text("Widget Settings")) {
                    Picker("Family", selection: $size) {
                        ForEach(BoardSize.allCases, id: \.self) { family in
                            Text(family.displayName).tag(family)
                        }
                    }
                    .onChange(of: size) { _, newSize in
                        if !validPatterns.contains(pattern) {
                            pattern = .auto
                        }
                    }
                    
                    Stepper("Populated Slots: \(slots)", value: $slots, in: 1...12)
                    
                    Picker("Layout Pattern", selection: $pattern) {
                        ForEach(validPatterns, id: \.self) { validPattern in
                            Text(validPattern.displayName).tag(validPattern)
                        }
                    }
                }
                
                Section(header: Text("Design")) {
                    Picker("Theme", selection: $theme) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    
                    Picker("Density", selection: $density) {
                        ForEach(Density.allCases, id: \.self) { density in
                            Text(density.displayName).tag(density)
                        }
                    }
                    
                    Picker("Internal Corners", selection: $corners) {
                        ForEach(InternalCorners.allCases, id: \.self) { corner in
                            Text(corner.displayName).tag(corner)
                        }
                    }
                }
            }
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
        let rawNames = (0..<slots).map { BoardSample.names[$0 % BoardSample.names.count] }
        let resolved = BoardGrid.resolve(
            count: slots,
            size: size,
            density: density,
            longestName: rawNames.map(\.count).max() ?? 0,
            pattern: pattern,
            corners: corners
        )
        let grid = resolved.grid
        let names = Array(rawNames.prefix(resolved.visibleSlots))
        
        return BoardView(grid: grid, count: names.count) { index in
            SlotFace(
                name: names[index],
                surface: theme.surface(at: index, accented: false),
                label: theme.labelColor(accented: false),
                mode: grid.mode,
                font: grid.font,
                cornerRadius: grid.cornerRadius
            )
        }
        .frame(width: size.canvas.width, height: size.canvas.height)
        .background { BoardBackground(theme: theme, accented: false) }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
        }
    }
}

#Preview {
    ControlPaneView()
}
