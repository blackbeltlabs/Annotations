import Foundation
import CoreGraphics

public struct Arrow: TwoPointsModel, Figure {
  public var id: String = UUID().uuidString
  public var colour: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
}
