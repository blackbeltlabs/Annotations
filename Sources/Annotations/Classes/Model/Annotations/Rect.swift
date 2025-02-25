import Foundation
import CoreGraphics

public enum RectModelType: String, Codable, Sendable {
  case regular
  case obfuscate
  case highlight
}

public struct Rect: RectBased, TwoPointsModel, Figure, Sizeable, Sendable {
  public static let defaultLineWidth = 5.0
  
  public var rectType: RectModelType
  
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 0
    
  public var lineWidth: CGFloat = Self.defaultLineWidth
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  
  public init(rectType: RectModelType,
              id: String = UUID().uuidString,
              color: ModelColor = .defaultColor(),
              zPosition: CGFloat = 0,
              lineWidth: CGFloat = Self.defaultLineWidth,
              origin: AnnotationPoint,
              to: AnnotationPoint) {
    self.rectType = rectType
    self.id = id
    self.color = color
    self.zPosition = zPosition
    self.lineWidth = lineWidth
    self.origin = origin
    self.to = to
  }
    
  public struct Mocks {
    public static var mockRegular: Rect {
      .init(rectType: .regular,
            color: .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
            origin: .init(x: 80, y: 120), to: .init(x: 100, y: 100))
    }
    
    public static var mockObfuscate: Rect {
      .init(rectType: .obfuscate,
            color: .init(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),
            origin: .init(x: 180, y: 80),
            to: .init(x: 100, y: 100))
    }
    
    public static var mockHighlight: Rect {
      .init(rectType: .highlight,
            color: .init(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),
            origin: .init(x: 100, y: 100),
            to: .init(x: 200, y: 200))
    }
    
    public static var mockHighlight2: Rect {
      .init(rectType: .highlight,
            color: .init(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),
            origin: .init(x: 250, y: 250),
            to: .init(x: 350, y: 350))
    }
    
    public static var mockHighlight3: Rect {
      .init(rectType: .highlight,
            color: .init(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),
            origin: .init(x: 300, y: 300),
            to: .init(x: 350, y: 350))
    }
    
    public static var mockRegularAsHighlight: Rect {
      .init(rectType: .regular,
            color: .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            origin: .init(x: 300, y: 300),
            to: .init(x: 350, y: 350))
    }
  }
}
