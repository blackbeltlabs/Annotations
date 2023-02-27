import Foundation
import CoreGraphics

public struct Pen: Figure, Sizeable {
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 0
  public var points: [AnnotationPoint] = []
  public var lineWidth: CGFloat = 5.0
  
  public struct Mocks {
    public static var mock: Pen {
      .init(color: .fuschia,
            points: [.init(x: 350, y: 150),
                     .init(x: 355, y: 240),
                     .init(x: 345, y: 290)])
    }
  }
}
