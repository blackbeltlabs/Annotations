import Foundation
import CoreGraphics

public struct Pen: Figure, Sizeable {
  public static let defaultLineWidth = 5.0
  
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 0
  public var points: [AnnotationPoint] = []
  public var lineWidth: CGFloat = Self.defaultLineWidth
  
  public init(id: String = UUID().uuidString,
              color: ModelColor ,
              zPosition: CGFloat = 0,
              points: [AnnotationPoint],
              lineWidth: CGFloat = Self.defaultLineWidth) {
    self.id = id
    self.color = color
    self.zPosition = zPosition
    self.points = points
    self.lineWidth = lineWidth
  }
  
  public struct Mocks {
    public static var mock: Pen {
      .init(color: .fuschia,
            points: [.init(x: 350, y: 150),
                     .init(x: 355, y: 240),
                     .init(x: 345, y: 290)])
    }
  }
}
