import Foundation
import CoreGraphics

public struct Text: TwoPointsModel {
  public var type: RectModelType = .regular
  
  public var id: String = UUID().uuidString
  public var colour: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var style: TextParams = TextParams()
  
  public var legibilityEffectEnabled: Bool = false
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
}
