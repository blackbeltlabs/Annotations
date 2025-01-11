import Foundation
import CoreGraphics

public struct Arrow: TwoPointsModel, Figure, Sizeable, Sendable {
  
  public static let defaultLineWidth = 5.0
  
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var lineWidth: CGFloat = Self.defaultLineWidth
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  
  public init(id: String = UUID().uuidString,
              color: ModelColor,
              zPosition: CGFloat = 0,
              lineWidth: CGFloat = Self.defaultLineWidth,
              origin: AnnotationPoint,
              to: AnnotationPoint) {
    
    self.id = id
    self.color = color
    self.zPosition = zPosition
    self.lineWidth = lineWidth
    self.origin = origin
    self.to = to
  }
  
  public struct Mocks {
    public static var mock: Arrow {
      .init(color: .green,
            origin: .init(x: 10, y:  10),
            to: .init(x: 80, y: 80))
    }
  }
}
