import Foundation
import CoreGraphics

public struct Text: AnnotationModel, TwoPointsModel {
  
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var style: TextParams = TextParams()
  
  public var legibilityEffectEnabled: Bool = false
  
  public var text: String = ""
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint = .zero// not used now but can be supported in the future
  
  public struct Mocks {
    public static var mockText1: Text {
      .init(color: .zero,
            zPosition: 1,
            style: .init(fontName: "Apple Chancery", foregroundColor: .init(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)),
            text: "Blackbelt Labs",
            origin: .init(x: 50, y: 50))
    }
  }
}

// Adapter for Text Anotations part

extension Text: TextAnnotationModelable {
  public var frame: CGRect {
    return CGRect(x: origin.x, y: origin.y, width: 0.0, height: 0.0)
  }
}
