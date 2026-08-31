import Foundation
import CoreGraphics

public struct BoardLayoutValues: Codable, Sendable, Equatable, Hashable {
    public var columns: Int
    public var marginX: CGFloat
    public var marginY: CGFloat
    public var spacingX: CGFloat
    public var spacingY: CGFloat
    public var paddingX: CGFloat
    public var paddingY: CGFloat
    public var cornerRadius: CGFloat
    public var outerCornerRadius: CGFloat
    
    public init(
        columns: Int = 0,
        marginX: CGFloat,
        marginY: CGFloat,
        spacingX: CGFloat,
        spacingY: CGFloat,
        paddingX: CGFloat,
        paddingY: CGFloat,
        cornerRadius: CGFloat,
        outerCornerRadius: CGFloat? = nil
    ) {
        self.columns = columns
        self.marginX = marginX
        self.marginY = marginY
        self.spacingX = spacingX
        self.spacingY = spacingY
        self.paddingX = paddingX
        self.paddingY = paddingY
        self.cornerRadius = cornerRadius
        self.outerCornerRadius = outerCornerRadius ?? cornerRadius
    }
}
