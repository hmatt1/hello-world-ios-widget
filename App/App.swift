import SwiftUI

@main
struct LauncherBoardApp: App {
    @AppStorage("lastEditedPresetId", store: UserDefaults(suiteName: "group.com.hmatt1.launcherboard"))
    var lastEditedPresetId: String = BoardPresetStore.defaultPresetId.uuidString

    var body: some Scene {
        WindowGroup {
            PresetEditorWrapper(lastEditedId: $lastEditedPresetId)
        }
    }
}

struct PresetEditorWrapper: View {
    @Binding var lastEditedId: String
    @State private var showingPresets = false
    
    var body: some View {
        NavigationStack {
            PresetEditorView(presetId: UUID(uuidString: lastEditedId) ?? BoardPresetStore.defaultPresetId)
                .id(lastEditedId) // Force recreate when switching presets
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingPresets = true
                        } label: {
                            Label("Presets", systemImage: "list.bullet")
                        }
                    }
                }
                .sheet(isPresented: $showingPresets) {
                    PresetListView(selectedId: $lastEditedId, isPresented: $showingPresets)
                }
        }
    }
}
