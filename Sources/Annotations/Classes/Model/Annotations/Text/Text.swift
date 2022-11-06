import Foundation
import CoreGraphics

public struct Text: AnnotationModel, TwoPointsModel, RectBased {
  
  public var id: String = UUID().uuidString
  
  public var color: ModelColor {
    get {
      style.foregroundColor ?? .orange
    }
    set {
      style.foregroundColor = newValue
    }
  }
  
  public var zPosition: CGFloat = 10
  
  public var style: TextParams = TextParams()
  
  public var legibilityEffectEnabled: Bool = false
  
  public var text: String = ""
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  
  var displayEmojiPicker: Bool = false
  
  public struct Mocks {
    public static var mockText1: Text {
      .init(zPosition: 1,
            style: .init(fontName: "Apple Chancery", fontSize: 10.0, foregroundColor: .init(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)),
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
  
  // render frame can be different from frame that is used in some logic calculation
  // render frame contains additional height to ensure that legibility text frame isn't clipped
  public var renderFrame: CGRect {
    var frame = self.frame
    let height = LegibilityTextHeightCalculator.lineWidth(for: style.fontSize ?? 0)
    frame.size.height += height
    
    // need integral here to ensure integer values for text view rendered frame
    // without this statement the layout() method of canvasView is called every time
    // textView frame is updated that lead to redundant calls and unpredicated behaviour
    let integralFrame = frame.integral
    
    return integralFrame
  }
  
  mutating func updateFrameSize(_ size: CGSize) {
    var currentFrame = frame
    currentFrame.size = size
    self.frame = currentFrame
  }
}


extension Text {
  var attributedText: NSAttributedString {
    NSAttributedString(string: text, attributes: style.attributes)
  }
}
