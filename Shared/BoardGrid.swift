import Foundation
import SwiftUI

/// The three widget families the board supports.
enum BoardSize: CaseIterable, Sendable {
    case small
    case medium
    case large

    var displayName: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }

    /// Slots the family can show legibly. Also the matrix's per-family maximum.
    var capacity: Int {
        switch self {
        case .small: return 4
        case .medium: return 6
        case .large: return 12
        }
    }

    /// The smallest canvas iOS gives this family, from the 320 x 568 pt
    /// layout a 4.7 inch iPhone reaches with Display Zoom on. Layout is
    /// clamped against this rather than against the largest phone, so the
    /// touch-target floor holds on every device and tiles only ever grow.
    var canvas: CGSize {
        switch self {
        case .small: return CGSize(width: 141, height: 141)
        case .medium: return CGSize(width: 291, height: 141)
        case .large: return CGSize(width: 291, height: 299)
        }
    }
}

/// How one tile arranges itself.
enum TileMode: Equatable, Sendable {
    /// Full width, name on the left.
    case row
    /// Equal share of a grid, name centred.
    case tile

    /// Space a name loses to the tile's own inset.
    var inset: CGFloat {
        switch self {
        case .row: return 28
        case .tile: return 12
        }
    }

    /// A wide short bar has room for two lines; a square tile has room for
    /// three, which is what lets a long name stay large.
    var lineLimit: Int {
        switch self {
        case .row: return 2
        case .tile: return 3
        }
    }

    /// Rounded even when tiles are flush, because at zero gap the corner
    /// notch is the only thing separating one tap target from the next, and
    /// in accented mode every tile has the same fill.
    var corner: CGFloat {
        switch self {
        case .row: return 16
        case .tile: return 14
        }
    }
}

/// A resolved board. Everything the view layer needs, with no measurement.
struct BoardGrid: Sendable {
    let columns: Int
    let rows: Int
    let mode: TileMode
    let gap: CGFloat
    let padding: CGFloat
    let font: Font
    let corners: InternalCorners

    static func resolve(
        count: Int,
        size: BoardSize,
        density: Density,
        longestName: Int,
        pattern: LayoutPattern = .auto,
        corners: InternalCorners = .rounded
    ) -> (grid: BoardGrid, visibleSlots: Int) {
        
        let requestedSlots = max(1, count)
        let dims = layoutDimensions(for: requestedSlots, size: size, pattern: pattern)
        let cols = dims.columns
        let rows = dims.rows
        
        let visibleSlots = min(requestedSlots, cols * rows)
        
        let mode: TileMode = cols == 1 && visibleSlots > 1 ? .row : .tile

        // Only the vertical axis can run out of room, so that is the budget.
        // Separation between tiles is spent first and outer padding gets the
        // remainder, which keeps both non-decreasing as density rises: giving
        // padding priority let a looser setting end up with a tighter board.
        let slack = max(0, size.canvas.height - minimumTarget * CGFloat(rows))
        let gap: CGFloat
        let padding: CGFloat
        if rows > 1 {
            let gapBudget = min(density.gap * CGFloat(rows - 1), slack)
            gap = gapBudget / CGFloat(rows - 1)
            padding = min(density.padding, max(0, slack - gapBudget) / 2)
        } else {
            gap = density.gap
            padding = min(density.padding, slack / 2)
        }
        let cell = cellSize(columns: cols, rows: rows, gap: gap, padding: padding, size: size)

        let grid = BoardGrid(
            columns: cols,
            rows: rows,
            mode: mode,
            gap: gap,
            padding: padding,
            font: textStyle(cell: cell, mode: mode, longestName: longestName),
            corners: corners
        )
        return (grid, visibleSlots)
    }

    private static func layoutDimensions(for slots: Int, size: BoardSize, pattern: LayoutPattern) -> (columns: Int, rows: Int) {
        func autoLayout() -> (Int, Int) {
            let cols = columnCount(for: min(slots, size.capacity), size: size)
            let rows = Int(ceil(Double(min(slots, size.capacity)) / Double(cols)))
            return (cols, rows)
        }

        switch pattern {
        case .auto:
            return autoLayout()
        case .singleHero:
            return (1, 1)
        case .verticalStack, .verticalList:
            let maxRows = Int(size.canvas.height / minimumTarget)
            return (1, min(slots, maxRows))
        case .horizontalStack, .horizontalStrip:
            let maxCols = Int(size.canvas.width / minimumTarget)
            return (min(slots, maxCols), 1)
        case .gridMatrix:
            if slots <= 1 { return (1, 1) }
            let cols = balanced(slots)
            let rows = Int(ceil(Double(slots) / Double(cols)))
            let maxRows = Int(size.canvas.height / minimumTarget)
            return (cols, min(rows, maxRows))
        case .dualColumnGrid:
            if slots <= 1 { return (1, 1) }
            let cols = 2
            let rows = Int(ceil(Double(slots) / Double(cols)))
            let maxRows = Int(size.canvas.height / minimumTarget)
            return (cols, min(rows, maxRows))
        }
    }

    /// Apple's minimum comfortable touch target.
    private static let minimumTarget: CGFloat = 44

    private static func cellSize(
        columns: Int,
        rows: Int,
        gap: CGFloat,
        padding: CGFloat,
        size: BoardSize
    ) -> CGSize {
        let width = size.canvas.width - padding * 2 - gap * CGFloat(columns - 1)
        let height = size.canvas.height - padding * 2 - gap * CGFloat(rows - 1)
        return CGSize(
            width: max(1, width / CGFloat(columns)),
            height: max(1, height / CGFloat(rows))
        )
    }

    private static func columnCount(for slots: Int, size: BoardSize) -> Int {
        guard slots > 1 else { return 1 }
        switch size {
        case .small:
            return slots <= 3 ? 1 : 2
        case .medium:
            return slots <= 3 ? slots : (slots == 4 ? 2 : 3)
        case .large:
            return slots <= 3 ? 1 : balanced(slots)
        }
    }

    /// Column counts chosen so rows stay even.
    private static func balanced(_ slots: Int) -> Int {
        switch slots {
        case 4: return 2
        case 5, 6: return 3
        case 7, 8: return 4
        case 9: return 3
        default: return 4
        }
    }

    /// The ladder of text styles, largest first, with the point size each one
    /// resolves to at the default Dynamic Type setting.
    private static let ladder: [(font: Font, points: CGFloat)] = [
        (.largeTitle, 34),
        (.title, 28),
        (.title2, 22),
        (.title3, 20),
        (.headline, 17),
        (.subheadline, 15),
        (.footnote, 13),
        (.caption, 12)
    ]

    /// The largest style whose longest name still fits the tile in both
    /// directions. Sizing to the names rather than to the geometry alone is
    /// what keeps a board at one size: without it, a single long name shrinks
    /// only its own tile and the grid loses its only ordering principle.
    /// `minimumScaleFactor` in the view is then a safety net, not the
    /// mechanism.
    private static func textStyle(cell: CGSize, mode: TileMode, longestName: Int) -> Font {
        let width = max(1, cell.width - mode.inset)
        let characters = CGFloat(max(4, longestName))
        let lines = CGFloat(mode.lineLimit)

        for step in ladder {
            // 0.55 em is a reasonable average advance for a semibold sans face.
            let needed = step.points * 0.55 * characters
            let used = min(lines, max(1, (needed / width).rounded(.up)))
            let fitsWidth = used <= lines
            let fitsHeight = cell.height >= step.points * 1.25 * used + 6
            if fitsWidth && needed <= width * lines && fitsHeight {
                return step.font
            }
        }
        return .caption
    }
}

/// Placeholder names, shared by the widget's gallery card and the in-app
/// preview so both show the same thing.
enum BoardSample {
    static let names = ["Focus", "Coffee", "Drive", "Gym", "Lights", "Notes", "Music", "Timer", "Read"]
}
