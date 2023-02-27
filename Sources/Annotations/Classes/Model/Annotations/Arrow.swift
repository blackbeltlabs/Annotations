import Foundation
import CoreGraphics

public struct Arrow: TwoPointsModel, Figure, Sizeable {
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var lineWidth: CGFloat = 5.0
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  
  public struct Mocks {
    public static var mock: Arrow {
      .init(color: .green,
            origin: .init(x: 10, y:  10),
            to: .init(x: 80, y: 80))
    }
  }
}
