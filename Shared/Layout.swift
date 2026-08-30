import Foundation
import SwiftUI



public enum BackgroundStyle: String, Codable, CaseIterable, Sendable {
    case theme
    case liquidGlass
    case glassTiles
    case transparent
    
    var displayName: String {
        switch self {
        case .theme: return "Theme (Solid)"
        case .liquidGlass: return "Liquid Glass (Container)"
        case .glassTiles: return "Liquid Glass (Buttons)"
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
