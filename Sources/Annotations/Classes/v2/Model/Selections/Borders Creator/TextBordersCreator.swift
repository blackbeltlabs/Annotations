import Foundation

class TextBordersCreator {
  static func bordersRect(for text: Text) -> CGRect {
    let frame = CGRect.rect(fromPoint: text.origin.cgPoint,
                            toPoint: text.to.cgPoint)
    return frame.insetBy(dx: -5.0,
                         dy: -10.0)
  }
  
  static func borderLineWidth(for text: Text) -> CGFloat {
    2.0
  }
}
