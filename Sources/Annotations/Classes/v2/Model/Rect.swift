import Foundation
import CoreGraphics

public enum RectModelType: String, Codable {
  case regular
  case obfuscate
  case highlight
}

public struct Rect: RectBased, Figure {
  
  public var rectType: RectModelType
  
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  
  public var points: [AnnotationPoint] = []
  
  public struct Mocks {
    public static var mockRegular: Rect {
      .init(rectType: .regular,
            color: .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
            origin: .init(x: 80, y: 120), to: .init(x: 100, y: 100))
    }
  }
}
