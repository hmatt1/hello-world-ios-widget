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
        PresetEditorView(presetId: UUID(uuidString: lastEditedId) ?? BoardPresetStore.defaultPresetId)
            .id(lastEditedId) // Force recreate when switching presets
            .overlay(alignment: .topLeading) {
                Button {
                    showingPresets = true
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.leading, 16)
                .padding(.top, 16)
            }
            .sheet(isPresented: $showingPresets) {
                PresetListView(selectedId: $lastEditedId, isPresented: $showingPresets)
            }
    }
}
