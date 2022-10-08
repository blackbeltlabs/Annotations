import Foundation
import CoreGraphics

public struct Text: AnnotationModel, TwoPointsModel, RectBased {
  
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 10
  
  public var style: TextParams = TextParams()
  
  public var legibilityEffectEnabled: Bool = false
  
  public var text: String = ""
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  
  public struct Mocks {
    public static var mockText1: Text {
      .init(color: .zero,
            zPosition: 1,
            style: .init(fontName: "Apple Chancery", foregroundColor: .init(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)),
            text: "Blackbelt Labs",
            origin: .init(x: 50, y: 50),
            to: .init(x: 200, y: 200))
    }
  }
}

// Adapter for Text Anotations part

extension Text {
  public var frame: CGRect {
    get {
      CGRect(fromPoint: origin.cgPoint, toPoint: to.cgPoint)
    }
    set {
      origin = CGPoint(x: newValue.minX, y: newValue.minY).modelPoint
      to = CGPoint(x: newValue.maxX, y: newValue.maxY).modelPoint
    }
  }
  
  mutating func updateFrameSize(_ size: CGSize) {
    var currentFrame = frame
    currentFrame.size = size
    self.frame = currentFrame
  }
}