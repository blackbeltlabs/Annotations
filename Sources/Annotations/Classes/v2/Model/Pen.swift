import Foundation
import CoreGraphics

public struct Pen: Figure {
  public var id: String = UUID().uuidString
  public var colour: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var points: [AnnotationPoint] = []
}
