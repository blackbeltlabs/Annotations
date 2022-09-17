import Foundation
import CoreGraphics

public enum RectModelType: String, Codable {
  case regular
  case obfuscate
  case highlight
  case number
}

public struct Rect: TwoPointsModel, Figure {
  
  public var type: RectModelType = .regular
  
  public var id: String = UUID().uuidString
  public var colour: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  
  public var points: [AnnotationPoint] = []
}
