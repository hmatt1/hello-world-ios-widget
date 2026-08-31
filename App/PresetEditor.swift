import SwiftUI
import WidgetKit
import PhotosUI

struct PresetEditorView: View {
    let presetId: UUID
    @ObservedObject var store = BoardPresetStore.shared
    
    @State private var size: BoardSize = .medium
    @State private var slots: Int = 4
    
    @State private var preset: BoardPreset
    @State private var wallpaperItem: PhotosPickerItem?
    @State private var widgetPosition: WidgetPosition = .topLeft
    
    @ObservedObject private var wallpaperStore = WallpaperStore.shared
    
    init(presetId: UUID) {
        self.presetId = presetId
        let p = BoardPresetStore.shared.presets.first(where: { $0.id == presetId }) ?? BoardPresetStore.createDefaultPreset()
        _preset = State(initialValue: p)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                boardView
            }
            .frame(height: size.canvas.height + 60)
            .animation(.spring(), value: size)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Unified Control Card
                        VStack(spacing: 0) {
                            
                            // NAME
                            HStack {
                                Text("Name")
                                Spacer()
                                TextField("Preset Name", text: $preset.name)
                                    .multilineTextAlignment(.trailing)
                                    .disabled(preset.id == BoardPresetStore.defaultPresetId)
                            }
                            .padding()
                            Divider().padding(.leading)
                            
                            // PREVIEW SETTINGS
                            VStack(spacing: 16) {
                                Picker("Size", selection: $size) {
                                    Text("S").tag(BoardSize.small)
                                    Text("M").tag(BoardSize.medium)
                                    Text("L").tag(BoardSize.large)
                                }
                                .pickerStyle(.segmented)
                                
                                Stepper("Preview Slots: \(slots)", value: $slots, in: 1...12)
                            }
                            .padding()
                            Divider().padding(.leading)
                            
                            // LAYOUT
                            VStack(spacing: 16) {
                                Menu {
                                    ForEach(DensityTemplate.all) { template in
                                        Button(template.name) {
                                            applyTemplate(template)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text("Density Template")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(currentTemplateName)
                                            .foregroundColor(.secondary)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .imageScale(.small)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Stepper(preset.columns == 0 ? "Columns: Auto" : "Columns: \(preset.columns)", value: $preset.columns, in: 0...12)
                                
                                Stepper("Margin X: \(Int(preset.marginX))", value: $preset.marginX, in: 0...40)
                                Stepper("Margin Y: \(Int(preset.marginY))", value: $preset.marginY, in: 0...40)
                                Stepper("Spacing X: \(Int(preset.spacingX))", value: $preset.spacingX, in: 0...40)
                                Stepper("Spacing Y: \(Int(preset.spacingY))", value: $preset.spacingY, in: 0...40)
                                Stepper("Padding X: \(Int(preset.paddingX))", value: $preset.paddingX, in: 0...40)
                                Stepper("Padding Y: \(Int(preset.paddingY))", value: $preset.paddingY, in: 0...40)
                                Stepper("Inner Corners: \(Int(preset.cornerRadius))", value: $preset.cornerRadius, in: 0...32)
                                Stepper("Outer Corners: \(Int(preset.outerCornerRadius))", value: $preset.outerCornerRadius, in: 0...32)
                            }
                            .padding()
                            Divider().padding(.leading)
                            
                            // BACKGROUND
                            VStack(spacing: 16) {
                                Picker("Style", selection: $preset.background) {
                                    ForEach(BackgroundStyle.allCases, id: \.self) { style in
                                        Text(style.displayName).tag(style)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                if preset.background == .theme {
                                    Picker("Theme", selection: $preset.theme) {
                                        ForEach(Theme.allCases, id: \.self) { t in
                                            Text(t.displayName).tag(t)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                if preset.background == .transparent || preset.background == .glassTiles {
                                    PhotosPicker(selection: $wallpaperItem, matching: .images) {
                                        HStack {
                                            Text("Upload Wallpaper")
                                            Spacer()
                                            if wallpaperStore.image != nil {
                                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                            }
                                        }
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
                                    
                                    Picker("Widget Position", selection: $widgetPosition) {
                                        ForEach(WidgetPosition.allCases, id: \.self) { pos in
                                            Text(pos.displayName).tag(pos)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    
                                    Stepper("Fine-tune X: \(Int(preset.bgOffsetX))", value: $preset.bgOffsetX, in: -100...100)
                                    Stepper("Fine-tune Y: \(Int(preset.bgOffsetY))", value: $preset.bgOffsetY, in: -100...100)
                                }
                            }
                            .padding()
                            
                        }
                        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.6))
                        .cornerRadius(20)
                        .padding()
                        
                        if preset.id == BoardPresetStore.defaultPresetId {
                            Button("Reset to Original") {
                                store.resetToOriginal(id: preset.id)
                                if let p = store.presets.first(where: { $0.id == presetId }) {
                                    preset = p
                                }
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .background(.regularMaterial)
        }
        .background {
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }

        .onChange(of: preset) { _, newPreset in
            store.update(newPreset)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private var currentTemplateName: String {
        for template in DensityTemplate.all {
            if preset.marginX == template.layout.marginX &&
               preset.marginY == template.layout.marginY &&
               preset.spacingX == template.layout.spacingX &&
               preset.spacingY == template.layout.spacingY &&
               preset.paddingX == template.layout.paddingX &&
               preset.paddingY == template.layout.paddingY &&
               preset.cornerRadius == template.layout.cornerRadius {
                return template.name
            }
        }
        return "Custom"
    }
    
    private func applyTemplate(_ template: DensityTemplate) {
        preset.marginX = template.layout.marginX
        preset.marginY = template.layout.marginY
        preset.spacingX = template.layout.spacingX
        preset.spacingY = template.layout.spacingY
        preset.paddingX = template.layout.paddingX
        preset.paddingY = template.layout.paddingY
        preset.cornerRadius = template.layout.cornerRadius
    }
    
    private var boardView: some View {
        let rawNames = (0..<slots).map { BoardSample.names[$0 % BoardSample.names.count] }
        let layout = preset.layoutValues
        
        let resolved = BoardGrid.resolve(
            count: slots,
            size: size,
            longestName: rawNames.map(\.count).max() ?? 0,
            layout: layout
        )
        let grid = resolved.grid
        let names = Array(rawNames.prefix(resolved.visibleSlots))
        
        return BoardView(grid: grid, count: names.count) { index, col, row in
            SlotFace(
                name: names[index],
                surface: preset.theme.surface(at: index, accented: false),
                label: preset.theme.labelColor(accented: false),
                mode: grid.mode,
                font: grid.font,
                paddingX: grid.layout.paddingX,
                paddingY: grid.layout.paddingY,
                topLeadingRadius: grid.topLeadingRadius(col: col, row: row),
                bottomLeadingRadius: grid.bottomLeadingRadius(col: col, row: row),
                bottomTrailingRadius: grid.bottomTrailingRadius(col: col, row: row),
                topTrailingRadius: grid.topTrailingRadius(col: col, row: row),
                style: preset.background,
                accented: false
            )
        }
        .frame(width: size.canvas.width, height: size.canvas.height)
        .background { 
            BoardBackground(
                theme: preset.theme,
                accented: false,
                style: preset.background,
                position: widgetPosition,
                family: size,
                offsetX: preset.bgOffsetX,
                offsetY: preset.bgOffsetY
            ) 
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
        }
    }
    
    private func themeIcon(_ theme: Theme) -> some View {
        let colors = theme.spec.background
        return Group {
            if colors.count >= 2 {
                LinearGradient(colors: colors.map(\.color), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else if let first = colors.first {
                first.color
            } else {
                Color.clear
            }
        }
        .frame(width: 20, height: 20)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
    }
}
