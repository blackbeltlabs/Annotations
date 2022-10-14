import Foundation

class TextBordersCreator {
  static func bordersRect(for text: Text) -> CGRect {
    TextSelectionPathCreator.selectionRect(for: text)
  }
  
  static func borderLineWidth(for text: Text) -> CGFloat {
    2.0
  }
}
