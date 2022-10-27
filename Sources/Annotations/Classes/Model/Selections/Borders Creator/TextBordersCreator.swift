import Foundation

class TextBordersCreator {
  static func bordersRect(for text: Text) -> CGRect {
    TextSelectionPathCreator.selectionRect(for: text)
  }
  
  static func legibilityFrameRect(for text: Text) -> CGRect {
    let rect = bordersRect(for: text)
    return CGRect(origin: .init(x: rect.origin.x,
                                y: rect.maxY + 4.0),
                  size: .init(width: 23,
                              height: 23))
  }
  
  static func borderLineWidth(for text: Text) -> CGFloat {
    2.0
  }
}
