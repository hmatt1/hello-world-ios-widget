import SwiftUI

/// A literal sRGB triple. Themes are the product's identity, so their colors
/// are declared by hand rather than derived from system colors.
struct RGB: Sendable {
    let red: Double
    let green: Double
    let blue: Double

    init(_ hex: UInt32) {
        red = Double((hex >> 16) & 0xFF) / 255
        green = Double((hex >> 8) & 0xFF) / 255
        blue = Double(hex & 0xFF) / 255
    }

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue)
    }
}

struct ThemeSpec: Sendable {
    /// Tile surfaces. Empty means the theme is monochrome and tiles use the
    /// label color at low opacity instead.
    let accents: [RGB]
    /// One color for a flat background, two for a gradient.
    let background: [RGB]
    /// Label color. Every accent above clears 4.5:1 against it.
    let label: RGB
}

/// Five looked-at combinations, in place of a combinatorial style matrix.
public enum Theme: String, Codable, CaseIterable, Sendable {
    case ink
    case paper
    case midnight
    case aurora
    case sunset

    var displayName: String {
        switch self {
        case .ink: return "Ink"
        case .paper: return "Paper"
        case .midnight: return "Midnight"
        case .aurora: return "Aurora"
        case .sunset: return "Sunset"
        }
    }

    var spec: ThemeSpec {
        switch self {
        case .ink:
            return ThemeSpec(
                accents: [],
                background: [RGB(0x0B0B0C)],
                label: RGB(0xF5F5F7)
            )
        case .paper:
            return ThemeSpec(
                accents: [],
                background: [RGB(0xF7F4EF)],
                label: RGB(0x111014)
            )
        case .midnight:
            return ThemeSpec(
                accents: [RGB(0x3B5BDB), RGB(0x1971C2), RGB(0x5F3DC4), RGB(0x7048B6), RGB(0xC2255C), RGB(0x2C5FA8)],
                background: [RGB(0x0B1020), RGB(0x161E3C)],
                label: RGB(0xFFFFFF)
            )
        case .aurora:
            return ThemeSpec(
                accents: [RGB(0x0B7A5B), RGB(0x2B7A3F), RGB(0x557A0B), RGB(0x0E7490), RGB(0x0F766E), RGB(0x4D7C0F)],
                background: [RGB(0x05201A), RGB(0x0A3328)],
                label: RGB(0xFFFFFF)
            )
        case .sunset:
            return ThemeSpec(
                accents: [RGB(0xC92A2A), RGB(0xC2410C), RGB(0xA9346B), RGB(0x862E9C), RGB(0x364FC7), RGB(0x8F5B10)],
                background: [RGB(0x1B0B14), RGB(0x321224)],
                label: RGB(0xFFFFFF)
            )
        }
    }
}


