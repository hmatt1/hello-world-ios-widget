import SwiftUI

struct ThemeListView: View {
    @ObservedObject var store = BoardThemeStore.shared
    @Binding var selectedId: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.themes) { theme in
                    Button {
                        selectedId = theme.id.uuidString
                        isPresented = false
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(theme.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Custom Color Theme")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedId == theme.id.uuidString {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteTheme(theme)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            store.duplicate(id: theme.id)
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button {
                            store.duplicate(id: theme.id)
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }
                        
                        Button(role: .destructive) {
                            deleteTheme(theme)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: store.reorder)
            }
            .navigationTitle("Themes")
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
                        let newTheme = store.create(name: "New Theme")
                        selectedId = newTheme.id.uuidString
                        isPresented = false
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func deleteTheme(_ theme: BoardTheme) {
        store.delete(id: theme.id)
        if selectedId == theme.id.uuidString {
            selectedId = store.themes.first?.id.uuidString ?? ""
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let theme = store.themes[index]
                deleteTheme(theme)
        }
    }
}
