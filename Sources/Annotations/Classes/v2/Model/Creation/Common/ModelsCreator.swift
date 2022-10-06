import Foundation
import CoreGraphics

final class ModelsCreator {
  static func createModelFromTwoPoints(createModeType: CanvasItemType,
                                       first: CGPoint,
                                       second: CGPoint,
                                       zPosition: CGFloat,
                                       color: ModelColor) -> AnnotationModel {
    
    let firstPoint = first.modelPoint
    let secondPoint = second.modelPoint
    switch createModeType {
    case .arrow:
      return Arrow(color: color, zPosition: zPosition, origin: firstPoint, to: secondPoint)
    case .pen:
      return Pen(color: color, zPosition: zPosition, points: [firstPoint, secondPoint])
    case .rect:
      return Rect(rectType: .regular, color: color, zPosition: zPosition, origin: firstPoint, to: secondPoint)
    case .obfuscate:
      return Rect(rectType: .obfuscate, color: color, zPosition: zPosition, origin: firstPoint, to: secondPoint)
    case .highlight:
      return Rect(rectType: .highlight, color: color, zPosition: zPosition, origin: firstPoint, to: secondPoint)
    default:
      fatalError()
    }
  }
}
