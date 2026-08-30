import SwiftUI

extension Theme {
    /// Tile fill. In accented mode the system keeps the opacity of translucent
    /// content and tints it, so a faint chip is what preserves the board's
    /// structure once the color is taken away.
    func surface(at index: Int, accented: Bool) -> Color {
        if accented {
            return .white.opacity(0.18)
        }
        let accents = spec.accents
        guard !accents.isEmpty else {
            return spec.label.color.opacity(0.12)
        }
        return accents[index % accents.count].color
    }

    /// iOS tints primary content white in accented mode, so naming white
    /// directly matches the device and keeps the in-app preview honest.
    /// `.primary` would follow the app's light or dark appearance instead.
    func labelColor(accented: Bool) -> Color {
        accented ? .white : spec.label.color
    }
}

/// Widget background. The system replaces this in accented mode, so it draws
/// nothing there rather than fighting for the same pixels.
struct BoardBackground: View {
    let theme: Theme
    let accented: Bool

    var body: some View {
        let colors = accented ? [] : theme.spec.background
        if colors.count >= 2 {
            LinearGradient(
                colors: colors.map(\.color),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if let first = colors.first {
            first.color
        } else {
            Color.clear
        }
    }
}

/// One tile. The name is the shortcut's own name, so it is always the truth.
struct SlotFace: View {
    let name: String
    let surface: Color
    let label: Color
    let mode: TileMode
    let font: Font

    var body: some View {
        Text(name)
            .font(font)
            .fontWeight(.semibold)
            .foregroundStyle(label)
            .lineLimit(mode.lineLimit)
            .minimumScaleFactor(0.6)
            .multilineTextAlignment(mode == .row ? .leading : .center)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(.horizontal, mode.inset / 2)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: mode == .row ? .leading : .center
            )
            .background {
                // The fill is inset by half a point on every side, so two
                // flush tiles leave a hairline of the background between them.
                // At Edge there is no gap, and in accented mode, Ink and Paper
                // every tile carries the same fill, so this line is the only
                // thing marking where one tap target ends. The target itself
                // is the full frame and is unaffected.
                RoundedRectangle(cornerRadius: mode.corner, style: .continuous)
                    .fill(surface)
                    .padding(0.5)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(name)
    }
}

/// Rows of equal tiles. No measurement, no geometry reader.
struct BoardView<Tile: View>: View {
    let grid: BoardGrid
    let count: Int
    let tile: (Int) -> Tile

    init(grid: BoardGrid, count: Int, @ViewBuilder tile: @escaping (Int) -> Tile) {
        self.grid = grid
        self.count = count
        self.tile = tile
    }

    var body: some View {
        VStack(spacing: grid.gap) {
            ForEach(0..<grid.rows, id: \.self) { row in
                HStack(spacing: grid.gap) {
                    ForEach(0..<grid.columns, id: \.self) { column in
                        let index = row * grid.columns + column
                        if index < count {
                            tile(index)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
        }
        .padding(grid.padding)
    }
}

/// Shown when no shortcut is assigned. Two words is the whole instruction,
/// so it gets the same type discipline as a tile: this is the only thing the
/// product ever tells anyone, and it has to survive Larger Text and Bold Text.
struct BoardEmptyState: View {
    let theme: Theme
    let accented: Bool

    var body: some View {
        Text("Edit Widget")
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(theme.labelColor(accented: accented).opacity(0.75))
            .lineLimit(2)
            .minimumScaleFactor(0.6)
            .multilineTextAlignment(.center)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
