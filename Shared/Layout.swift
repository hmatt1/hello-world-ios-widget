import Foundation
import SwiftUI

enum LayoutPattern: String, CaseIterable, Sendable {
    case auto
    case singleHero
    case verticalStack
    case horizontalStack
    case gridMatrix
    case horizontalStrip
    case verticalList
    case dualColumnGrid
    
    var displayName: String {
        switch self {
        case .auto: return "Auto (Best Fit)"
        case .singleHero: return "Single Hero"
        case .verticalStack: return "Vertical Stack"
        case .horizontalStack: return "Horizontal Stack"
        case .gridMatrix: return "Grid Matrix"
        case .horizontalStrip: return "Horizontal Strip"
        case .verticalList: return "Vertical List"
        case .dualColumnGrid: return "Dual Column Grid"
        }
    }
}

enum InternalCorners: String, CaseIterable, Sendable {
    case rounded
    case square
    case sharp
    
    var displayName: String {
        switch self {
        case .rounded: return "Rounded"
        case .square: return "Square"
        case .sharp: return "Sharp"
        }
    }
}

enum BackgroundStyle: String, CaseIterable, Sendable {
    case theme
    case liquidGlass
    case transparent
    
    var displayName: String {
        switch self {
        case .theme: return "Theme (Solid)"
        case .liquidGlass: return "Liquid Glass"
        case .transparent: return "Transparent"
        }
    }
}

enum WidgetPosition: String, CaseIterable, Sendable {
    case topLeft, topRight
    case middleLeft, middleRight
    case bottomLeft, bottomRight
    case top, middle, bottom
    
    var displayName: String {
        switch self {
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .middleLeft: return "Middle Left"
        case .middleRight: return "Middle Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        case .top: return "Top"
        case .middle: return "Middle"
        case .bottom: return "Bottom"
        }
    }
}
