import SwiftUI
import WidgetKit
import PhotosUI

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
    @State private var backgroundStyle: BackgroundStyle = .theme
    @State private var widgetPosition: WidgetPosition = .topLeft
    @State private var wallpaperItem: PhotosPickerItem?
    
    @ObservedObject private var wallpaperStore = WallpaperStore.shared

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
        ZStack {
            // Immersive Background
            if let img = wallpaperStore.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            // Native iOS Widget Edit Blur
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Static Preview Window
                ZStack {
                    board(theme)
                        .animation(.default, value: size)
                        .animation(.default, value: slots)
                        .animation(.default, value: pattern)
                        .animation(.default, value: theme)
                        .animation(.default, value: density)
                        .animation(.default, value: corners)
                        .animation(.default, value: backgroundStyle)
                        .animation(.default, value: widgetPosition)
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
                    .pickerStyle(.segmented)
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
                
                Section(header: Text("Background")) {
                    Picker("Style", selection: $backgroundStyle) {
                        ForEach(BackgroundStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    
                    if backgroundStyle == .theme {
                        Picker("Theme", selection: $theme) {
                            ForEach(Theme.allCases, id: \.self) { t in
                                HStack {
                                    themeIcon(t)
                                    Text(t.displayName)
                                }
                                .tag(t)
                            }
                        }
                    }
                    
                    if backgroundStyle == .transparent {
                        VStack(alignment: .leading, spacing: 6) {
                            PhotosPicker(selection: $wallpaperItem, matching: .images) {
                                HStack {
                                    Text("Upload Screenshot")
                                    Spacer()
                                    if wallpaperStore.image != nil {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                    }
                                }
                            }
                            
                            Text("Enter Jiggle mode, swipe to a blank page, and take a screenshot.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .onChange(of: wallpaperItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    await MainActor.run {
                                        wallpaperStore.save(image: uiImage, screenBounds: UIScreen.main.bounds.size)
                                    }
                                }
                            }
                        }
                        
                        Picker("Preview Position", selection: $widgetPosition) {
                            ForEach(WidgetPosition.allCases, id: \.self) { pos in
                                Text(pos.displayName).tag(pos)
                            }
                        }
                    }
                }
                
                Section(header: Text("Design")) {
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
                    .pickerStyle(.segmented)
                }
            }
            .scrollContentBackground(.hidden)
        }
        } // Close ZStack
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
        .background { 
            BoardBackground(
                theme: theme,
                accented: false,
                style: backgroundStyle,
                position: widgetPosition,
                family: size
            ) 
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func themeIcon(_ theme: Theme) -> some View {
        let colors = theme.spec.background.map(\.color)
        Circle()
            .fill(colors.count >= 2 ? 
                  AnyShapeStyle(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)) : 
                  AnyShapeStyle(colors.first ?? .clear))
            .frame(width: 16, height: 16)
            .overlay(Circle().strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

#Preview {
    ControlPaneView()
}
