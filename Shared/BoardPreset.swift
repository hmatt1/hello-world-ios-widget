import Foundation
import CoreGraphics

public struct BoardPreset: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var columns: Int
    public var marginX: CGFloat
    public var marginY: CGFloat
    public var spacingX: CGFloat
    public var spacingY: CGFloat
    public var paddingX: CGFloat
    public var paddingY: CGFloat
    public var cornerRadius: CGFloat
    public var theme: Theme
    public var background: BackgroundStyle
    public var bgOffsetX: CGFloat
    public var bgOffsetY: CGFloat

    public init(
        id: UUID = UUID(),
        name: String,
        columns: Int,
        marginX: CGFloat,
        marginY: CGFloat,
        spacingX: CGFloat,
        spacingY: CGFloat,
        paddingX: CGFloat,
        paddingY: CGFloat,
        cornerRadius: CGFloat,
        theme: Theme,
        background: BackgroundStyle,
        bgOffsetX: CGFloat = 0,
        bgOffsetY: CGFloat = 0
    ) {
        self.id = id
        self.name = name
        self.columns = columns
        self.marginX = marginX
        self.marginY = marginY
        self.spacingX = spacingX
        self.spacingY = spacingY
        self.paddingX = paddingX
        self.paddingY = paddingY
        self.cornerRadius = cornerRadius
        self.theme = theme
        self.background = background
        self.bgOffsetX = bgOffsetX
        self.bgOffsetY = bgOffsetY
    }

    enum CodingKeys: CodingKey {
        case id, name, columns, marginX, marginY, spacingX, spacingY, paddingX, paddingY, cornerRadius, theme, background, bgOffsetX, bgOffsetY
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        columns = try container.decode(Int.self, forKey: .columns)
        marginX = try container.decode(CGFloat.self, forKey: .marginX)
        marginY = try container.decode(CGFloat.self, forKey: .marginY)
        spacingX = try container.decode(CGFloat.self, forKey: .spacingX)
        spacingY = try container.decode(CGFloat.self, forKey: .spacingY)
        paddingX = try container.decode(CGFloat.self, forKey: .paddingX)
        paddingY = try container.decode(CGFloat.self, forKey: .paddingY)
        cornerRadius = try container.decode(CGFloat.self, forKey: .cornerRadius)
        theme = try container.decode(Theme.self, forKey: .theme)
        background = try container.decode(BackgroundStyle.self, forKey: .background)
        bgOffsetX = try container.decodeIfPresent(CGFloat.self, forKey: .bgOffsetX) ?? 0
        bgOffsetY = try container.decodeIfPresent(CGFloat.self, forKey: .bgOffsetY) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(columns, forKey: .columns)
        try container.encode(marginX, forKey: .marginX)
        try container.encode(marginY, forKey: .marginY)
        try container.encode(spacingX, forKey: .spacingX)
        try container.encode(spacingY, forKey: .spacingY)
        try container.encode(paddingX, forKey: .paddingX)
        try container.encode(paddingY, forKey: .paddingY)
        try container.encode(cornerRadius, forKey: .cornerRadius)
        try container.encode(theme, forKey: .theme)
        try container.encode(background, forKey: .background)
        try container.encode(bgOffsetX, forKey: .bgOffsetX)
        try container.encode(bgOffsetY, forKey: .bgOffsetY)
    }

    public var layoutValues: BoardLayoutValues {
        BoardLayoutValues(
            columns: columns,
            marginX: marginX,
            marginY: marginY,
            spacingX: spacingX,
            spacingY: spacingY,
            paddingX: paddingX,
            paddingY: paddingY,
            cornerRadius: cornerRadius
        )
    }
}
