import SwiftUI

/// A literal sRGB triple. Themes are the product's identity, so their colors
/// are declared by hand rather than derived from system colors.
public struct RGB: Sendable, Codable, Equatable {
    public var red: Double
    public var green: Double
    public var blue: Double

    public init(_ hex: UInt32) {
        red = Double((hex >> 16) & 0xFF) / 255
        green = Double((hex >> 8) & 0xFF) / 255
        blue = Double(hex & 0xFF) / 255
    }

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public var color: Color {
        get { Color(.sRGB, red: red, green: green, blue: blue) }
        set {
            if let components = UIColor(newValue).cgColor.components {
                if components.count >= 3 {
                    self.red = Double(components[0])
                    self.green = Double(components[1])
                    self.blue = Double(components[2])
                }
            }
        }
    }
}

public struct ThemeSpec: Sendable, Codable, Equatable {
    /// Tile surfaces. Empty means the theme is monochrome and tiles use the
    /// label color at low opacity instead.
    public var accents: [RGB]
    /// One color for a flat background, two for a gradient.
    public var background: [RGB]
    /// Label colors for each shortcut.
    public var labels: [RGB]
    
    public init(accents: [RGB], background: [RGB], labels: [RGB]) {
        self.accents = accents
        self.background = background
        self.labels = labels
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accents = try container.decode([RGB].self, forKey: .accents)
        background = try container.decode([RGB].self, forKey: .background)
        
        if let singleLabel = try? container.decode(RGB.self, forKey: .labels) {
            labels = Array(repeating: singleLabel, count: 12)
        } else if let labelsArray = try? container.decode([RGB].self, forKey: .labels) {
            labels = labelsArray
        } else {
            labels = Array(repeating: RGB(0xFFFFFF), count: 12)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case accents
        case background
        case labels = "label" // map old "label" key to "labels"
    }
}

public struct BoardTheme: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var spec: ThemeSpec
    
    public init(id: UUID = UUID(), name: String, spec: ThemeSpec) {
        self.id = id
        self.name = name
        self.spec = spec
    }
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
                labels: Array(repeating: RGB(0xF5F5F7), count: 12)
            )
        case .paper:
            return ThemeSpec(
                accents: [],
                background: [RGB(0xF7F4EF)],
                labels: Array(repeating: RGB(0x111014), count: 12)
            )
        case .midnight:
            return ThemeSpec(
                accents: [RGB(0x3B5BDB), RGB(0x1971C2), RGB(0x5F3DC4), RGB(0x7048B6), RGB(0xC2255C), RGB(0x2C5FA8)],
                background: [RGB(0x0B1020), RGB(0x161E3C)],
                labels: Array(repeating: RGB(0xFFFFFF), count: 12)
            )
        case .aurora:
            return ThemeSpec(
                accents: [RGB(0x0B7A5B), RGB(0x2B7A3F), RGB(0x557A0B), RGB(0x0E7490), RGB(0x0F766E), RGB(0x4D7C0F)],
                background: [RGB(0x05201A), RGB(0x0A3328)],
                labels: Array(repeating: RGB(0xFFFFFF), count: 12)
            )
        case .sunset:
            return ThemeSpec(
                accents: [RGB(0xC92A2A), RGB(0xC2410C), RGB(0xA9346B), RGB(0x862E9C), RGB(0x364FC7), RGB(0x8F5B10)],
                background: [RGB(0x1B0B14), RGB(0x321224)],
                labels: Array(repeating: RGB(0xFFFFFF), count: 12)
            )
        }
    }
}


