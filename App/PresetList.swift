import SwiftUI

struct PresetListView: View {
    @ObservedObject var store = BoardPresetStore.shared
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.presets) { preset in
                    NavigationLink(destination: PresetEditorView(presetId: preset.id)) {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                                .font(.headline)
                            Text(preset.id == BoardPresetStore.defaultPresetId ? "Built-in" : "Custom")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if preset.id != BoardPresetStore.defaultPresetId {
                            Button(role: .destructive) {
                                store.delete(id: preset.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        
                        Button {
                            store.duplicate(id: preset.id)
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }
                        .tint(.blue)
                    }
                }
                .onMove(perform: store.reorder)
            }
            .navigationTitle("Presets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        _ = store.create(name: "New Preset")
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
