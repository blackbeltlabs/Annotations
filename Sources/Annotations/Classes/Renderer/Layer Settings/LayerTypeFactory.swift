import Foundation

class LayerTypeFactory {
  static func layerType(for figure: Figure) -> LayerType {
    switch figure {
    case let rect as Rect:
      switch rect.rectType {
      case .obfuscate:
        return .obfuscate
      case .highlight:
        return .highlight
      default:
        return .normal
      }
    default:
      return .normal
    }
  }
}
