import Foundation
import SwiftUI
import WidgetKit

@MainActor
public class BoardThemeStore: ObservableObject {
    public static let shared = BoardThemeStore()
    
    private let defaults = AppGroup.defaults
    private let key = "board_themes"
    
    @Published public private(set) var themes: [BoardTheme] = []
    
    private init() {
        themes = BoardThemeStore.loadRaw()
    }
    
    public static nonisolated func loadRaw() -> [BoardTheme] {
        guard let defaults = AppGroup.defaults,
              let data = defaults.data(forKey: "board_themes"),
              let loaded = try? JSONDecoder().decode([BoardTheme].self, from: data),
              !loaded.isEmpty else {
            return createDefaultThemes()
        }
        return loaded
    }
    
    public static nonisolated func loadTheme(id: UUID) -> BoardTheme {
        let all = loadRaw()
        return all.first { $0.id == id } ?? all.first ?? createDefaultThemes().first!
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(themes) {
            defaults?.set(encoded, forKey: key)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    public static nonisolated func createDefaultThemes() -> [BoardTheme] {
        return Theme.allCases.enumerated().map { index, theme in
            let stableId = UUID(uuidString: "11111111-1111-1111-1111-\(String(format: "%012x", index))")!
            return BoardTheme(
                id: stableId,
                name: theme.displayName,
                spec: theme.spec
            )
        }
    }
    
    public func create(name: String) -> BoardTheme {
        let newTheme = BoardTheme(
            id: UUID(),
            name: name,
            spec: Theme.midnight.spec
        )
        themes.append(newTheme)
        save()
        return newTheme
    }
    
    public func duplicate(id: UUID) {
        guard let existing = themes.first(where: { $0.id == id }) else { return }
        let newTheme = BoardTheme(
            id: UUID(),
            name: existing.name + " Copy",
            spec: existing.spec
        )
        if let index = themes.firstIndex(where: { $0.id == id }) {
            themes.insert(newTheme, at: index + 1)
        } else {
            themes.append(newTheme)
        }
        save()
    }
    
    public func update(_ theme: BoardTheme) {
        guard let index = themes.firstIndex(where: { $0.id == theme.id }) else { return }
        themes[index] = theme
        save()
    }
    
    public func delete(id: UUID) {
        guard themes.count > 1 else { return }
        themes.removeAll { $0.id == id }
        save()
    }
    
    public func reorder(from source: IndexSet, to destination: Int) {
        themes.move(fromOffsets: source, toOffset: destination)
        save()
    }
}
