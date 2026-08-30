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
