import SwiftUI

struct PresetListView: View {
    @ObservedObject var store = BoardPresetStore.shared
    @Binding var selectedId: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.presets) { preset in
                    Button {
                        selectedId = preset.id.uuidString
                        isPresented = false
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(preset.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(preset.id == BoardPresetStore.defaultPresetId ? "Built-in" : "Custom")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedId == preset.id.uuidString {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if preset.id != BoardPresetStore.defaultPresetId {
                            Button(role: .destructive) {
                                store.delete(id: preset.id)
                                if selectedId == preset.id.uuidString {
                                    selectedId = BoardPresetStore.defaultPresetId.uuidString
                                }
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let newPreset = store.create(name: "New Preset")
                        selectedId = newPreset.id.uuidString
                        isPresented = false
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
