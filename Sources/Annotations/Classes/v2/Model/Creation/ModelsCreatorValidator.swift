import Foundation
import CoreGraphics

class ModelsCreatorValidator {
  static func isModelValid(for createMode: CanvasItemType,
                           firstPoint: CGPoint,
                           secondPoint: CGPoint) -> Bool {
    switch createMode {
    case .arrow:
      return CGPoint.distanceBetween(point1: firstPoint,
                                     point2: secondPoint) >= 10
    case .pen, .rect, .obfuscate, .highlight:
      return CGPoint.distanceBetween(point1: firstPoint,
                                     point2: secondPoint) >= 5
    default:
      return false
    }
  }
}
