import Foundation
import CoreGraphics

public struct Pen: Figure {
  public var id: String = UUID().uuidString
  public var colour: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var points: [AnnotationPoint] = []
  
  
  public struct Mocks {
    public static var mock: Pen {
      .init(colour: .fuschia,
            points: [.init(x: 350, y: 150),
                     .init(x: 355, y: 240),
                     .init(x: 345, y: 290)])
    }
  }
}
